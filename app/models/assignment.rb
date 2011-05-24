class Assignment < ActiveRecord::Base

  attr_accessible :user, :user_id, :project, :project_id, :role

  # owner - owns the project an may opt to delete it.
  # editor - may edit translation on the given project
  ROLES = %w(owner editor)

  belongs_to :user
  belongs_to :project

end
