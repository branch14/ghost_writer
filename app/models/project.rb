class Project < ActiveRecord::Base

  SNAPSHOT_PATH = File.join Rails.root, %w(public system snapshots)

  attr_accessor :reset_translations, :reset_counters
  attr_accessible :title, :permalink, :locales_attributes,
                  :reset_translations, :reset_counters

  has_many :tokens
  has_many :locales
  has_many :translations, :through => :locales
  has_many :assignments
  has_many :users, :through => :assignments
  has_many :snapshots, :as => :attachable

  accepts_nested_attributes_for :locales

  validates :title, :presence => true
  validates :permalink, :presence => true,
    :format => { :with => /[:alphanum:-]+/ },
    :length => { :minimum => 4 }

  after_update :perform_reset_translations!, :if => :reset_translations
  # after_update :perform_reset_counters!, :if => :reset_counters

  def remaining_locales
    codes = locales.map &:code
    Locale.available.reject { |key, value| codes.include? key }
  end

  def aggregated_translations2(locales=nil)
    locales ||= self.locales
    locales.inject({}) do |result, locale|
      tree = tokens.roots.inject({}) do |provis, root|
        provis.merge strip_down(root.subtree.arrange, locale)
      end
      result.merge locale.code => tree
    end
  end

  # TODO this will go after migration to ancestry
  def aggregated_translations
    # assumption everything has been loaded eagerly
    locales.inject({}) do |result, locale|
      tokens.inject(result) do |provis, token|
        translation = token.translations.select { |t| t.locale_id == locale.id }.first
        if !translation.nil? and translation.active?
          provis.deep_merge nesting(locale.code, token.raw, translation.content)
        else
          provis
        end
      end
    end
  end

  def new_snapshot_name
    time = I18n.l Time.now, :format => :filename
    name = "translations_%s_%s.yml" % [ permalink, time ]
    File.join SNAPSHOT_PATH, name
  end
  
  # TODO this will go after migration to ancestry
  def log(msg)
    if @log.nil?
      @log = File.open(File.join(Rails.root, %w(log import.log)), 'a')
      @log.sync = true
    end
    @log.puts msg
  end

  def find_or_create_tokens(full_key)
    parent = tokens
    keys = full_key.split '.'
    Array.new.tap do |tokens|
      keys.each_with_index do |key, index|
        token = parent.at_depth(index).where(:key => key).first
        # FIXME use before_save callback
        # token ||= parent.create!(:key => key, :project => self)
        token ||= parent.build(:key => key, :project => self).tap { |t| t.update_full_key; t.save! }
        tokens << token
        parent = token.children
      end
    end
  end

  # TODO this will go after migration to ancestry
  def handle_missed!(filename)
    log "PROCESSING: #{filename}"
    data = File.open(filename, 'r').read
    missed = JSON.parse(data)  
    #File.open(filename.sub('.json', '.yaml'), 'w') { |f| f.puts missed.to_yaml }
    missed.each do |key, val|
      token = self.tokens.where(:raw => key).first
      if token.nil?
        token = self.tokens.create(:raw => key)
        token.translations.each do |translation|
          #attrs = { :hits => val['count'][translation.locale.code] }
          content = val['default'][translation.locale.code] unless val['default'].nil?
          content = val[:default][translation.locale.code] unless val[:default].nil?
          content ||= key
          #attrs[:content] = content unless content.nil?
          #translation.reload
          translation.content = content
          translation.miss_counter = val['count'][translation.locale.code]
          translation.save!
          log "NEW #{translation.locale.code}.#{key} => #{content}"
          unless translation.content == content
            log "ERROR"
            log val.to_yaml
          end
        end
      else
        token.translations.each do |translation|
          miss_counter = (translation.miss_counter || 0) + val['count'][translation.locale.code].to_i
          attrs = {}
          attrs[:miss_counter] = miss_counter
          content = val['default'][translation.locale.code] unless val['default'].nil?
          attrs[:content] = content unless content.nil?
          translation.update_attributes attrs
          log "UPDATE #{translation.locale.code}.#{key} => #{miss_counter} - #{content}"
        end
      end
    end
  end

  # options has one and only one of...
  #  * :filename 
  #  * :json a JSON String
  #  * :data a Hash
  def handle_missed2!(options)
    options[:json] = File.open(options[:filename], 'r').read if options.has_key?(:filename)
    options[:data] = JSON.parse(options[:json]) if options.has_key?(:json)  
    raise "no data supplied" if options[:data].nil? or options[:data].empty?
    options[:data].each do |key, val|
      token = find_or_create_tokens(key).last
      token.update_or_create_all_translations(normalize_attributes(val))
    end
  end

  # TODO adjust this method to incoming data
  def normalize_attributes(attrs)
    locales.map(&:code).inject({}) do |result, code|
      result.merge code => {
        'content' => attrs['default'][code],
        'miss_counter' => attrs['count'][code]
      }
    end
  end

  private

  def strip_down(tree, locale)
    Hash.new.tap do |result|
      tree.each do |token, value|
        result[token.key] = value.empty? ?
          token.translation_for(locale).content : strip_down(value, locale)
      end
    end
  end

  # TODO this has do go
  def nesting(locale, token, translation)
    keys = (token.split('.').reverse << locale)
    keys.inject(translation) { |result, key| { key => result } }
  end

  def perform_reset_translations!
    snapshots.create!
    tokens.destroy_all
  end

  def perform_reset_counters!
    translations.each &:reset_counters!
  end

end
