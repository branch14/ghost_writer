class ApplicationController < ActionController::Base

  protect_from_forgery

  layout proc { |controller| controller.request.xhr? ? false : 'application' }

  before_filter :authenticate_user!, :unless => :api_controller?
  
  private

  def api_controller?
    self.class.name == 'ApiController'
  end

end
