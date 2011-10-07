class Api::TranslationsController < ApplicationController

  skip_before_filter :authenticate_user!
  skip_before_filter :verify_authenticity_token
  before_filter :set_project!

  # Inital & Incremental requests
  # e.g. GET http://0.0.0.0:3000/api/91885ca9ec4feb9b2ed2423cdbdeda32/translations.json
  def index
    permalink = @project.permalink
    timestamp = request.if_modified_since
    data, last_modified = nil, nil

    if timestamp.blank? # sent all translations (Initial request)
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
      tokens = @project.tokens.changed_after(timestamp)
      data = tokens.inject({}) do |result, token|
        result.deep_merge token.translations_as_nested_hash
      end
      last_modified = tokens.empty? ? timestamp : Time.now
    end

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
    if params[:data] and params[:data].size > 2 # empty is '{}'
      filename = next_filename
      File.open(filename, 'w') { |f| f.puts params[:data] }
      @project.delay.handle_missed!(:filename => filename)
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
