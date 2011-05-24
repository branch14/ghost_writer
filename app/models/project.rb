class Project < ActiveRecord::Base

  attr_accessible :title, :permalink, :locales_attributes

  has_many :tokens
  has_many :locales
  has_many :translations, :through => :locales
  has_many :assignments
  has_many :users, :through => :assignments

  accepts_nested_attributes_for :locales

  validates :title, :presence => true
  validates :permalink, :presence => true,
    :format => { :with => /[:alphanum:-]+/ },
    :length => { :minimum => 4 }

  def remaining_locales
    codes = locales.map &:code
    Locale.available.reject { |key, value| codes.include? key }
  end

  def aggregated_translations
    locales.inject({}) do |result, locale|
      tokens.inject(result) do |provis, token|
        translation = token.translations.where(:locale_id => locale.id).first
        if !translation.nil? and translation.active?
          provis.deep_merge nesting(locale.code, token.raw, translation.content)
        else
          provis
        end
      end
    end
  end

  private

  def nesting(locale, token, translation)
    keys = (token.split('.').reverse << locale)
    keys.inject(translation) { |result, key| { key => result } }
  end

end
