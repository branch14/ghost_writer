source 'http://rubygems.org'

gem 'rails', '3.0.5'

# gems in alphabetic order
gem 'acts-as-taggable-on'
gem 'best_in_place'
gem 'delayed_job'
gem 'exception_notification_rails3', '1.2.0', :require => 'exception_notifier'
gem 'formtastic', '1.2.3'
gem 'haml', '3.1.1'
gem 'inherited_resources', '1.2.1'
gem 'json'
gem 'kaminari'
gem 'mysql'
gem 'devise'

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
group :development, :test do
  gem 'sqlite3-ruby', :require => 'sqlite3'
  gem 'yard'
  gem 'rspec-rails'
  gem 'capybara'
  gem 'steak'
  gem 'spork', "0.9.0.rc3"
  gem 'guard-rspec'
  gem 'guard-spork'
  gem 'guard-bundler'
  gem 'guard-compass'
  gem 'guard-passenger'
  gem 'guard-mozrepl'
  gem 'passenger'
  gem 'factory_girl_rails'
  gem 'compass'

  gem 'capistrano'
  gem 'capistrano-ext'

  # gem 'rails-footnotes', '>= 3.7'

#  Below an ideaf how to enable operating system dependant gems.
#  Sadly it does cause errors on deployment.
#  if RUBY_PLATFORM =~ /-*darwin.*/
#    gem 'growl'
#  end
  if RUBY_PLATFORM =~ /-*linux.*/
    gem 'libnotify'
  end

end
