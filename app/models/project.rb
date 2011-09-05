class Project < ActiveRecord::Base

  SNAPSHOT_PATH = File.join Rails.root, %w(public system snapshots)

  GHOSTREADER_MAPPING = {
    :default => :content,
    :count => :miss_counter
  }

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
    :format => { :with => /\A[\w-]+\z/ },
    :length => { :minimum => 4 }

  after_update :perform_reset_translations!, :if => :reset_translations
  # after_update :perform_reset_counters!, :if => :reset_counters

  def remaining_locales
    codes = locales.map &:code
    Locale.available.reject { |key, value| codes.include? key }
  end

  def aggregated_translations(options={})
    options = { :locales => options } unless options.is_a?(Hash)
    options[:locales] ||= self.locales
    options[:locales].inject({}) do |result, locale|
      tree = tokens.roots.inject({}) do |provis, root|
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

  def new_snapshot_name
    time = I18n.l Time.now, :format => :filename
    name = "translations_%s_%s.yml" % [ permalink, time ]
    File.join SNAPSHOT_PATH, name
  end
  
  # returns the found or created tokens, the leaf is last
  def find_or_create_tokens(full_key)
    parent = tokens
    keys = full_key.split '.'
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
  #  * :filename 
  #  * :json (a JSON String)
  #  * :data (a Hash)
  def handle_missed!(options)
    options[:json] = File.open(options[:filename], 'r').read if options.has_key?(:filename)
    options[:data] = JSON.parse(options[:json]) if options.has_key?(:json)  
    raise "no data supplied" if options[:data].blank?
    options[:data].each do |key, val|
      token = find_or_create_tokens(key).last
      token.update_or_create_all_translations(normalize_attributes(val))
    end
    File.delete(options[:filename]) if options.has_key?(:filename)
  end

  # TODO adjust this method to incoming data
  def normalize_attributes(attrs)
    locales.map(&:code).inject({}) do |result, code|
      result.tap do |provis|
        provis[code] = {}
        GHOSTREADER_MAPPING.each do |key, value|
          if attrs[key.to_s] && !attrs[key.to_s][code].blank?
            provis[code][value.to_s] = attrs[key.to_s][code]
          end
        end
      end
    end
  end

  def clear_cache!
    Rails.cache.write(permalink, nil)
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
    self.api_key = Digest::MD5.hexdigest(created_at.to_s + permalink)
  end

end
