class ApplicationController < ActionController::Base

  protect_from_forgery

  layout proc { |controller| controller.request.xhr? ? false : 'application' }

  before_filter :authenticate_user!

  def dj_running?
    !!%x[ps x].match(/rake dj:work/)
  end

end
