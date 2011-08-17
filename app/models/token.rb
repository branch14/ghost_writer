require 'base64'
require 'digest'

class Token < ActiveRecord::Base

  attr_accessible :project, :project_id, :key
  
  belongs_to :project
  has_many :translations, :dependent => :destroy

  has_ancestry :cache_depth => true
  
  validates :project, :presence => true
  validates :key, :presence => true #format...
  #validates :full_key, :presence => true #format...

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

  # returns a hash 
  def translations_by_code
    translations.inject({}) { |result, t| result.merge t.code => t }
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

  def translation_for(locale)
    translations.where(:locale_id => locale.id).first
  end

  def set_full_key
    self.full_key = (ancestors.map(&:key) << key) * '.'
  end

end

