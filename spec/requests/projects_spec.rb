require 'spec_helper'

describe "Projects" do
  before(:each) { @user = log_in }

  describe "GET /projects" do
    it "works! (now write some real specs)" do
      @user.projects.create
      @user.should have(1).project
      get projects_path
      response.status.should be(302)
    end
  end

  # describe "GET /projects" do
  #   it "works! (now write some real specs)" do
  #     2.times { @user.projects.create }
  #     @user.should have(2).projects
  #     get projects_path
  #     response.status.should be(200)
  #   end
  # end
  # 
  # describe "GET /projects/:id" do
  #   it "works! (now write some real specs)" do
  #     project = @user.projects.create
  #     get project_path(project.id)
  #     response.status.should be(200)
  #   end
  # end
end
