class Translation < ActiveRecord::Base

  attr_accessible :content, :locale, :token, :locale_id, :token_id

  belongs_to :locale
  belongs_to :token

  delegate :raw, :to => :token

  validates :locale, :presence => true
  validates :token, :presence => true

  acts_as_taggable

end
