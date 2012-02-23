class SnapshotsController < InheritedResources::Base

  def create
    create! { project_path(:id => @snapshot.attachable_id) }
  end

end
