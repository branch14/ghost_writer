class ApplicationController < ActionController::Base

  protect_from_forgery

  layout proc { |controller| controller.request.xhr? ? false : 'application' }

  before_filter :authenticate_user!
  
end
