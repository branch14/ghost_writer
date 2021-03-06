class Translation < ActiveRecord::Base

  attr_accessible :content, :locale, :token, :locale_id,
                  :token_id, :hits_counter, :miss_counter

  belongs_to :locale
  belongs_to :token

  delegate :code, :to => :locale
  delegate :full_key, :to => :token

  #validates :locale, :presence => true
  #validates :token, :presence => true, :unless => :new_record?

  #acts_as_taggable

  before_save :reset_blank_content
  before_save :set_active

  before_save :zero_counters!, :if => proc { |t| t.content_changed? and !t.miss_counter_changed? }

  private

  def reset_blank_content
    self.content = full_key if content.blank?
  end

  def set_active
    self.active = ( content != full_key )
    # see http://apidock.com/rails/ActiveRecord/RecordNotSaved
    nil
  end

  def reset_counters!
    zero_counters!
    save!
  end

  def zero_counters!
    self.attributes = attributes.merge :miss_counter => 0, :hits_counter => 0
  end

end
