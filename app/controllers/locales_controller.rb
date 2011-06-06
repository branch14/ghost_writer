class LocalesController < InheritedResources::Base

  belongs_to :project

  before_filter :load_translations, :only => :show

  private

  #def resource 
  #  @locale ||= Locale.where(:id => params[:id]).first
  #end

  def load_translations
    @translations = resource.translations.limit(10).order('hits DESC').includes(:token)
  end

end
