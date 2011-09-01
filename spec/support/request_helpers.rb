def log_in(options={})
  user = Factory.create(:user, options)
  visit "/users/sign_in"
  fill_in "user_email", :with => user.email
  fill_in "user_password", :with => user.password
  click_button "Sign in"
  user
end

#RSpec.configure do |config|
#  config.include Warden::Test::Helpers, :type => :acceptance
#  config.after(:each, :type => :acceptance) do
#    # NOTE Steak, Warden (w/ Devise) + OAuth2
#    # http://groups.google.com/group/steakrb/browse_thread/thread/3698c32b16a9b347
#    UserProfile.delete_all
#    Warden.test_reset!
#  end
#end
