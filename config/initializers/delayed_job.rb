Delayed::Job.class_eval do
  attr_accessible :priority, :payload_object
end
