require 'base64'
require 'digest'

class Token < ActiveRecord::Base

  attr_accessible :raw, :project, :project_id
  
  belongs_to :project
  has_many :translations, :dependent => :destroy

  validates :raw, :presence => true#, :format => { :with => /[:alphanum:.-]+/ }
  validates :project, :presence => true

  #before_save :hash_token!, :if => :raw_changed?
  after_create :prepop_translations!

  def hits_counter
    translations.sum(:hits_counter)
  end

  def miss_counter
    translations.sum(:miss_counter)
  end

  def has_interpolations?
    # todo
  end

  # returns an array of missing locales or an empty array otherwise
  def missing_translations
    project.locales.reject do |locale|
      translations.map(&:locale_id).include? locale.id
    end
  end

  private

  #def hash_token!
  #  self.hashed = Base64.encode64(Digest::MD5.hexdigest(raw))
  #end

  def prepop_translations!
    missing_translations.map do |locale|
      translations.create :locale => locale
    end
  end

end

