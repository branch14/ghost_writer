class Api::TranslationsController < ApplicationController

  skip_before_filter :authenticate_user!
  before_filter :set_project!

  # e.g. GET http://0.0.0.0:3000/api/91885ca9ec4feb9b2ed2423cdbdeda32/translations.json
  def index
    permalink = @project.permalink
    timestamp = request.env['If-Modified-Since']

    if timestamp.blank? # sent all translations
      data = Rails.cache.read(permalink)
      data ||= @project.aggregated_translations
      Rails.cache.write(permalink, data)
    else # only send diff (updated translations)
      tokens = @project.tokens.changed_after(timestamp)
      data = tokens.inject({}) do |result, token|
        result.deep_merge token.translations_as_nested_hash
      end
    end

    response.headers['Last-Modified'] = http_time
    # render :json => data
    send_data(data.to_json,
              :type => 'application/json',
              :filename => "translations_#{permalink}_.json")

    # TODO http://apidock.com/rails/ActionController/Streaming
  end

  # e.g. POST http://0.0.0.0:3000/api/91885ca9ec4feb9b2ed2423cdbdeda32/translations.json
  def create
    if params[:miss] and params[:miss].size > 2 # empty is {}
      @project.missings_in_json = params[:miss]
      @project.delay.handle_missed!
    end
    redirect_to api_translations_url(:api_key => @project.api_key)
  end

  private

  def set_project!
    @project = Project.find_by_api_key(params[:api_key])
    raise "No project with api key #{params[:api_key]} found." if @project.nil?
  end  

end
