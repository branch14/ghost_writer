class Api::TranslationsController < ApplicationController

  skip_before_filter :authenticate_user!
  skip_before_filter :verify_authenticity_token
  before_filter :set_project!

  # Initial & Incremental requests
  # e.g. GET http://0.0.0.0:3000/api/91885ca9ec4feb9b2ed2423cdbdeda32/translations.json
  #
  # Example for Incremental request
  #
  # GET /api/e0e948efc3606e00c4b981bb2d3f7463/translations.json HTTP/1.1
  # Content-Length: 0
  # If-Modified-Since: Tue, 11 Oct 2011 07:51:14 GMT
  # Host: ghost.panter.ch:80
  #
  def index
    permalink = @project.permalink
    timestamp = request.if_modified_since
    data, last_modified = nil, nil

    if timestamp.blank? # sent all translations (Initial request)
      logger.fatal "NO TIMESTAMP"
      if cache = false && Rails.cache.read(permalink) # temporarily deactivated
        data = cache[:data]
        last_modified = cache[:timestamp]
      else
        data = @project.aggregated_translations
        last_modified = Time.now
        Rails.cache.write(permalink, {
                            :data => data ,
                            :timestamp => last_modified
                          })
      end
    else # only send updated translations (Incremental request)
      logger.fatal "TIMESTAMP: #{timestamp}"
      tokens = @project.tokens.changed_after(timestamp)
      data = tokens.inject({}) do |result, token|
        result.deep_merge token.translations_as_nested_hash
      end
      last_modified = tokens.empty? ? timestamp : Time.now
    end

    logger.fatal "LAST-MODIFIED: #{last_modified}"
    response.last_modified = last_modified
    # render :json => data
    send_data(data.to_json,
              :type => 'application/json',
              :filename => "translations_#{permalink}.json")

    # TODO http://apidock.com/rails/ActionController/Streaming
  end

  # Reporting request
  # e.g. POST http://0.0.0.0:3000/api/91885ca9ec4feb9b2ed2423cdbdeda32/translations.json
  def create
    project_proxy = @project.delay
    project_proxy = @project if Rails.env.development? and !dj_running?
    if params[:data] and params[:data].size > 2 # empty is '{}'
      filename = next_filename
      File.open(filename, 'w') { |f| f.puts params[:data] }
      project_proxy.handle_missed!(:filename => filename)
    end
    redirect_to api_translations_url(:api_key => @project.api_key)
  end

  private

  def next_filename
    filename, counter = nil, 0
    while filename.nil? or File.exist?(filename)
      counter += 1
      filename = File.join(Rails.root, 'public', "#{@project.permalink}_%06d.json" % counter)
    end
    filename
  end

  def set_project!
    @project = Project.find_by_api_key(params[:api_key])
    raise "No project with api key #{params[:api_key]} found." if @project.nil?
  end  

end
