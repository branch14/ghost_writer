require 'base64'
require 'digest'

class Token < ActiveRecord::Base

  KEY_PATTERN = /\A[\w-]+\z/

  def self.changed_after(time)
    time = DateTime.parse(time) if time.is_a?(String)
    time = time.to_formatted_s(:db)
    self.includes(:translations).where(['translations.updated_at > ?', time])
  end

  attr_accessible :project, :project_id, :key
  
  belongs_to :project
  has_many :translations, :dependent => :destroy

  has_ancestry :cache_depth => true
  
  validates :project, :presence => true
  validates :key, :presence => true, :format => { :with => KEY_PATTERN }

  before_save :set_full_key

  # performs a three way merge of...
  #  * existing translations
  #  * missing translations
  #  * attributes provided
  def update_or_create_all_translations(attributes={})
    missing_locales.each { |locale| translations.build :locale => locale }
    translations.each do |translation|
      attrs = attributes[translation.code]
      unless translation.active? or attrs.nil?
        merger = translation.attributes.merge attrs
        translation.attributes = merger
      end
      translation.save!
    end
  end

  def translations_as_nested_hash
    translations.inject({}) do |result, translation|
      result.merge translation.locale.code => 
        full_key.split('.').reverse.inject(translation.content) { |result, key| { key => result } }
    end
  end

  def hits_counter
    translations.sum(:hits_counter)
  end

  def miss_counter
    translations.sum(:miss_counter)
  end

  # TODO
  def has_interpolations?
    false
  end

  # returns an array of missing locales or an empty array otherwise
  def missing_locales
    project.locales.reject do |locale|
      translations.map(&:locale_id).include? locale.id
    end
  end

  # returns a translation
  def translation_for(locale)
    translations.where(:locale_id => locale.id).first
  end

  def set_full_key
    self.full_key = (ancestors.map(&:key) << key) * '.'
  end

end

