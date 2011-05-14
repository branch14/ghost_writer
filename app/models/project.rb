class Project < ActiveRecord::Base

  attr_accessible :title, :permalink, :locales_attributes

  has_many :tokens
  has_many :locales
  has_many :translations, :through => :locales

  accepts_nested_attributes_for :locales

  validates :title, :presence => true
  validates :permalink, :presence => true,
    :format => { :with => /[:alphanum:-]+/ },
    :length => { :minimum => 4 }

  def remaining_locales
    codes = locales.map &:code
    Locale.available.reject { |key, value| codes.include? key }
  end

end
