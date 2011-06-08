class JobsController < InheritedResources::Base

  actions :index

  defaults :resource_class => Delayed::Job

end
