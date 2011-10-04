class ApplicationController < ActionController::Base

  protect_from_forgery

  layout proc { |controller| controller.request.xhr? ? false : 'application' }

  before_filter :authenticate_user!

  private

  def http_time(time=Time.now)
    time.strftime('%a, %d %b %Y %H:%M:%S %Z')
  end
  
end
