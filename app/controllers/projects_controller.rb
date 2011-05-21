class ProjectsController < InheritedResources::Base

  #append_before_filter :redirect_if_only_one_project

  private

  def resource
    @project ||= Project.where(:id => params[:id]).includes(:tokens).first
  end

  def redirect_if_only_one_project
    if collection.size == 1
      locale collection.first.locales.first
      redirect_to projects_locale_url(locale)
    end
  end

end
