# Re-definitions are appended to existing tasks
task :environment
task :merb_env

namespace :dj do
  desc "Clear the delayed_job queue."
  task :clear => [:environment] do
    Delayed::Job.delete_all
  end

  desc "Start a delayed_job worker."
  task :work => [:environment] do
    RAILS_DEFAULT_LOGGER.auto_flushing = 1
    RAILS_DEFAULT_LOGGER.info('activated auto flushing')
    Delayed::Worker.new(:min_priority => ENV['MIN_PRIORITY'], :max_priority => ENV['MAX_PRIORITY']).start
  end
end
