class Locale < ActiveRecord::Base

  FILE = File.join(Rails.root, %w(config languages.yml)) 

  attr_accessible :code, :title, :project, :project_id

  before_validation :set_title!, :on => :create

  validates :code, :presence => true#,
    #:format => { :with => /[:alpha:]{2}(|_[:alpha:]{2})/ }
  validates :title, :presence => true

  belongs_to :project
  has_many :translations

  validates :project, :presence => true

  #def to_param
  #  code
  #end

  class << self

    def available
      @available ||= File.open(FILE) { |yf| YAML::load(yf) }
    end

  end

  private

  def set_title!
    self.title = Locale.available[code]
  end

end
