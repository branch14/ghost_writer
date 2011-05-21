class Assignment < ActiveRecord::Base

  # owner - owns the project an may opt to delete it.
  # editor - may edit translation on the given project
  ROLES = %w(owner editor)

  belongs_to :user
  belongs_to :project

end
