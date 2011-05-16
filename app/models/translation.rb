class Translation < ActiveRecord::Base

  attr_accessible :content, :locale, :token, :locale_id, :token_id

  belongs_to :locale
  belongs_to :token

  delegate :raw, :to => :token

  validates :locale, :presence => true
  validates :token, :presence => true, :unless => :new_record?

  #acts_as_taggable

  before_validation :prepop_content!, :on => :create, :unless => :content?

  private

  def prepop_content!
    self.content = raw
  end

end
