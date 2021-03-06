class Project < ActiveRecord::Base

  SNAPSHOT_PATH = File.join Rails.root, %w(public system snapshots)

  GHOSTREADER_MAPPING = {
    :default => :content,
    :count => :miss_counter
  }

  attr_accessor :reset_translations, :reset_counters, :missings_in_json,
                :new_user_email, :save_static
  attr_accessible :title, :permalink, :locales_attributes,
                  :reset_translations, :reset_counters, :new_user_email,
                  :save_static

  has_many :tokens
  has_many :locales
  has_many :translations, :through => :locales
  has_many :assignments
  has_many :users, :through => :assignments
  has_many :snapshots, :as => :attachable

  accepts_nested_attributes_for :locales

  validates :title, :presence => true
  validates :permalink, :presence => true,
    :format => { :with => /\A[\w-]+\z/ },
    :length => { :minimum => 4 }

  after_update :perform_reset_translations!, :if => :reset_translations
  after_update :perform_reset_counters!, :if => :reset_counters
  after_update :do_save_static, :if => :save_static

  before_save :set_api_key, :unless => :api_key?
  before_save :add_user, :if => :new_user_email

  def remaining_locales
    codes = locales.map &:code
    Locale.available.reject { |key, value| codes.include? key }
  end

  def aggregated_translations(options={})
    options = { :locales => options } unless options.is_a?(Hash)
    options[:locales] ||= self.locales
    options[:locales].inject(ActiveSupport::OrderedHash.new) do |result, locale|
      tree = tokens.roots.inject(ActiveSupport::OrderedHash.new) do |provis, root|
        provis.merge strip_down(root.subtree.arrange, locale)
      end
      result.merge locale.code => tree
    end
  end

  # http://tools.ietf.org/html/rfc4180
  def to_csv
    tokens.reject(&:has_children?).map do |token|
      [ token.full_key,
        locales.map do |locale|
          '"%s"' % token.translation_for(locale).content.gsub('"', '""')
        end ] * ','
    end * "\n" + "\n"
  end

  def to_yaml_for_export
    aggregated_translations.ya2yaml(:syck_compatible => true)
  end

  def new_snapshot_name
    time = I18n.l Time.now, :format => :filename
    name = "translations_%s_%s.yml" % [ permalink, time ]
    File.join SNAPSHOT_PATH, name
  end
  
  # returns the found or created tokens, the leaf is last
  def find_or_create_tokens(full_key)
    parent = tokens
    keys = full_key.is_a?(String) ? full_key.split('.') : full_key
    if keys.reject { |k| k.match(Token::KEY_PATTERN) }.any?
      logger.error "Invalid key #{full_key.inspect} ignored."
      return nil
    end
    Array.new.tap do |tokens|
      keys.each_with_index do |key, index|
        token = parent.at_depth(index).where(:key => key).first
        # FIXME use before_save callback
        # token ||= parent.create!(:key => key, :project => self)
        token ||= parent.build(:key => key, :project => self).tap { |t| t.set_full_key; t.save! }
        tokens << token
        parent = token.children
      end
    end
  end

  # options should have exactly one of...
  #  * :filename (a path to a file containing JSON) 
  #  * :json (a JSON String)
  #  * :data (a Hash)
  #
  # Alternatively a JSON string may be stored in attr_accessor
  # 'missings_in_json' to have it available when the call is
  # dispatched via delayed_job. In that case :filename and :json
  # will be ignored.
  def handle_missed!(options = {})
    logger.info "Handling missed with options: #{options.inspect}"
    options[:json] = File.open(options[:filename], 'r').read if options.has_key?(:filename)
    options[:json] = missings_in_json unless missings_in_json.nil?
    options[:data] = JSON.parse(options[:json]) if options.has_key?(:json)  
    raise "no data supplied" if options[:data].blank?
    options[:data].each do |key, val|
      logger.info "Data: #{key} => #{val.inspect}"
      tokens = find_or_create_tokens(key)
      unless tokens.blank?
        token = tokens.last
        attrs = normalize_attributes(val)
        token.update_or_create_all_translations(attrs)
      end
    end
    if options.has_key?(:filename)
      logger.info "Removing file #{options[:filename]}"
      File.delete(options[:filename]) 
    end
  end

  def handle_import!(options = {})
    options[:json] = File.open(options[:filename], 'r').read if options.has_key?(:filename)
    options[:json] = missings_in_json unless missings_in_json.nil?
    options[:data] = JSON.parse(options[:json]) if options.has_key?(:json)
    raise "no data supplied" if options[:data].blank?
    # for all locales
    locales.each do |locale|
      data = options[:data][locale.code]
      unless data.nil?
        #Slogger.info "# processing #{data.inspect}"
        stats = import_tree(data, locale)
        Slogger.info "# final stats #{stats.inspect}, sum: #{stats.values.sum}"
      end
    end
    #if options.has_key?(:filename)
    #  logger.info "Removing file #{options[:filename]}"
    #  File.delete(options[:filename]) 
    #end
  end

  def import_tree(value, locale, prefix=[])
    stats = Hash.new { |h, k| h[k] = 0 }  
    stats[value.class.name] += 1
    case value
    when Hash
      value.each do |key, val|
        substats = import_tree(val, locale, prefix + [key])
        stats = substats.inject(stats) { |r, a| r[a[0]] += a[1]; r }
      end
    when String, NilClass
      make_entry(locale, prefix, value)
    else
      make_entry(locale, prefix, value.ya2yaml)
    end
    return stats
  end

  def make_entry(locale, prefix, value)
    #Slogger.info "token = Project.find(#{id}).find_or_create_tokens(#{prefix.inspect}).last"
    token = find_or_create_tokens(prefix).last
    Slogger.info "#{locale.code}.#{prefix.inspect} => #{token.inspect}"
    token.update_or_create_all_translations
    if value.is_a?(String)
      #Slogger.info "translation = token.translation_for(#{locale.code.inspect})"
      translation = token.translation_for(locale)
      unless translation.active?
        #Slogger.info "translation.update_attribute(:content, #{value.inspect})"
        translation.update_attribute(:content, value)
      else
        #Slogger.info "# translation is active"
      end
    end
  end

  # takes {"de"=>{"default"=>"Do not remind"}}
  # returns {'de'+>{'content'=>'Do not remind'},'en'=>{}}
  def normalize_attributes(attrs)
    locales.map(&:code).inject({}) do |result, code|
      result.tap do |provis|
        provis[code] = {}
        GHOSTREADER_MAPPING.each do |key, value|
          if attrs[code] && !attrs[code][key.to_s].blank?
            provis[code][value.to_s] = attrs[code][key.to_s]
          end
        end
      end
    end
  end

  def clear_cache!
    Rails.cache.write(permalink, nil)
  end

  def static_file_path
    File.join(STATIC_PATH, "#{api_key}.yml")
  end

  def static_file_time
    File.mtime(static_file_path) if File.exist?(static_file_path)
  end

  private

  def strip_down(tree, locale)
    Hash.new.tap do |result|
      tree.each do |token, value|
        if value.blank?
          translation = token.translation_for(locale)
          # FIXME translation.nil? cases
          if !translation.nil? && translation.active
            result[token.key] = translation.content
          end
        else
          subtree = strip_down(value, locale)
          result[token.key] = subtree unless subtree.empty?
        end
      end
    end
  end

  def perform_reset_translations!
    snapshots.create!
    tokens.destroy_all
    clear_cache!
  end

  def perform_reset_counters!
    translations.each &:reset_counters!
  end

  def set_api_key
    iso = (created_at || Time.now).strftime('%Y-%m-%d_%H:%M:%S')
    self.api_key = Digest::MD5.hexdigest([iso, permalink] * '_')
  end

  def add_user
    user = User.find_by_email(new_user_email)
    users << user unless user.nil?
  end

  def do_save_static
    File.open(static_file_path, 'w') { |f| f.puts to_yaml_for_export  }
  end

end
