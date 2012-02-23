class JobsController < InheritedResources::Base

  actions :index, :destroy

  defaults :resource_class => Delayed::Job

end
