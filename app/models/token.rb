require 'base64'
require 'digest'

class Token < ActiveRecord::Base

  attr_accessible :raw, :project, :project_id
  
  belongs_to :project
  has_many :translations, :dependent => :destroy

  #validates :raw_key, :format => { :with => // }
  validates :project, :presence => true

  before_save :hash_token!, :if => :raw_changed?
  #before_validation :prepop_content!, :on => :create, :unless => :content?

  def hits
    translations.sum(:hits)
  end

  def has_interpolations?
    # todo
  end

  private

  def hash_token!
    self.hashed = Base64.encode64(Digest::MD5.hexdigest(raw))
  end

  #def prepop_content!
  #  self.content = raw
  #end

end

