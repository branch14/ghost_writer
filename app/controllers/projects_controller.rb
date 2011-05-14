class ProjectsController < InheritedResources::Base

  private

  def resource
    @project ||= Project.where(:id => params[:id]).includes(:tokens).first
  end

end
