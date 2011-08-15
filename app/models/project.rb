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

  def aggregated_translations(locales=nil)
    locales ||= self.locales
    locales.inject({}) do |result, locale|
      tree = tokens.roots.inject({}) do |provis, root|
        provis.merge strip_down(root.subtree.arrange, locale)
      end
      result.merge locale.code => tree
    end
  end

  def new_snapshot_name
    time = I18n.l Time.now, :format => :filename
    name = "translations_%s_%s.yml" % [ permalink, time ]
    File.join SNAPSHOT_PATH, name
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

  # options has one and only one of...
  #  * :filename 
  #  * :json a JSON String
  #  * :data a Hash
  def handle_missed!(options)
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

  def perform_reset_translations!
    snapshots.create!
    tokens.destroy_all
  end

  def perform_reset_counters!
    translations.each &:reset_counters!
  end

  def set_api_key
    self.api_key = Digest::MD5.hexdigest(created_at.to_s + permalink)
  end

end
