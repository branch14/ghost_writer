class ProjectsController < InheritedResources::Base

  before_filter :redirect_if_only_one_project, :only => :index

  def show
    #resource.snapshots.build
    show!
  end

  def create
    @project = Project.new(params[:project])
    # @project.assignments.build :user_id => current_user.id, :role => 'owner'
    create!
    current_user.assignments.create! :project => @project, :role => 'owner'
  end

  private

  def resource
    @project ||= Project.where(:id => params[:id]).includes(:tokens).first
  end

  def collection
    @projects ||= current_user.projects
  end
  
  #def begin_of_association_chain
  #  current_user
  #end

  def redirect_if_only_one_project
    if collection.size == 1
      project = collection.first
      redirect_to project_locale_url(project, project.locales.first)
    end
  end

end
