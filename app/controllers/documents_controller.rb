class DocumentsController < InheritedResources::Base

  def create
    create! { project_path(:id => @document.attachable_id) }
  end

end
