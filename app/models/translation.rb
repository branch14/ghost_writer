class Translation < ActiveRecord::Base

  attr_accessible :content, :locale, :token, :locale_id, :token_id, :hits

  belongs_to :locale
  belongs_to :token

  delegate :raw, :to => :token

  #validates :locale, :presence => true
  #validates :token, :presence => true, :unless => :new_record?

  #acts_as_taggable

  #before_validation :prepop_content!, :on => :create, :unless => :content?
  before_save :set_activation!, :if => :content_changed? 
  before_save :nilify_blank_content!

  private

  #def prepop_content!
  #  self.content = raw
  #  self.active = false
  #end

  def set_activation!
    self.active = ( content != raw )
    # see http://apidock.com/rails/ActiveRecord/RecordNotSaved
    nil
  end

  def nilify_blank_content!
    self.content = nil of content.blank?
  end

end
