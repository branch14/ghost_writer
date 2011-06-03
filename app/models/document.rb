class Document < ActiveRecord::Base

  default_scope :order => 'created_at DESC'

  has_attached_file :attachment

  belongs_to :attachable, :polymorphic => true

  attr_accessible :type, :attachable_type, :attachable_id

  validates :attachable, :presence => true

end
