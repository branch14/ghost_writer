class LocalesController < InheritedResources::Base

  belongs_to :project

  private

  def resource 
    @locale ||= Locale.where(:id => params[:id]).includes(:translations).first
  end

end
