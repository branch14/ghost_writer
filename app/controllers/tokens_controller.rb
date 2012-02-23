class TokensController < InheritedResources::Base

  optional_belongs_to :project

  def destroy
    destroy! { :back }
  end

end
