require "base64"

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
    timestamp = request.if_modified_since # Time or nil
    data, last_modified = nil, nil

    if timestamp.blank? # sent all translations (Initial request)
      logger.info "Request: Initial (no timestamp)"
      if cache = false && Rails.cache.read(permalink) # temporarily deactivated
        data = cache[:data]
        last_modified = cache[:timestamp]
      else
        data = @project.aggregated_translations
        last_modified = Time.now.utc # Time
        Rails.cache.write(permalink, {
                            :data => data ,
                            :timestamp => last_modified
                          })
      end
    else # only send updated translations (Incremental request)
      timestamp = timestamp.utc
      logger.info "Request: Incremental (timestamp: #{timestamp})"
      tokens = @project.tokens.changed_after(timestamp)
      logger.info "# Tokens: #{tokens.size}"
      data = tokens.inject({}) do |result, token|
        result.deep_merge token.translations_as_nested_hash
      end
      last_modified = tokens.empty? ? timestamp : Time.now.utc
    end

    response.last_modified = last_modified
    #logger.info "Sending: timestamp=#{last_modified} data=#{data.inspect}"

    case params[:format]
      when nil, 'json'
      send_data(data.to_json, :type => 'application/json',
                :filename => "translations_#{permalink}.json")
      when 'yml'
      send_data(data.ya2yaml(:syck_compatible => true), :type => 'application/yaml',
                :filename => "translations_#{permalink}.yml")
    end
    # TODO http://apidock.com/rails/ActionController/Streaming
  end

  # Reporting request
  # e.g. POST http://0.0.0.0:3000/api/91885ca9ec4feb9b2ed2423cdbdeda32/translations.json
  def create
    # fork to import if structure is native
    return import if params[:structure] == 'native'
    logger.info "Request: Reporting"
    if params[:data] and params[:data].size > 2 # empty is '{}'
      logger.info "with #{params[:data].size} bytes of data"
      filename = next_filename
      File.open(filename, 'w') { |f| f.puts params[:data] }
      job = Delayed::Job.enqueue(HandleMissedJob.new(@project, filename))
      # handle synchronous if in development and dj not running
      Delayed::Worker.new.run(job) if Rails.env.development? and !dj_running?
    end
    redirect_to api_translations_url(:api_key => @project.api_key)
  end
  
  def import
    @import = true # for test
    logger.info "Request: Reporting (with #{params[:data].size} bytes of data)"
    data = Base64.decode64(params[:data])

    json = JSON.parse(data)
    leaves = number_of_leaves(json)
    keys = json.keys.size
    logger.info "number of keys: #{keys}, number of leaves: #{leaves}"

    filename = next_filename("import_k#{keys}_l#{leaves}")
    File.open(filename, 'w') { |f| f.puts data }
    job = Delayed::Job.enqueue(HandleImportJob.new(@project, filename))
    # handle synchronous if in development and dj not running
    Delayed::Worker.new.run(job) if Rails.env.development? and !dj_running?
    redirect_to api_translations_url(:api_key => @project.api_key)
  end

  class HandleMissedJob < Struct.new(:project, :filename)
    def perform
      project.handle_missed!(:filename => filename)
    end
  end

  class HandleImportJob < Struct.new(:project, :filename)
    def perform
      project.handle_import!(:filename => filename)
    end
  end

  private

  def number_of_leaves(nested_hash)
    return 1 unless nested_hash.is_a?(Hash)
    nested_hash.inject(0) do |result, key_val|
      result + number_of_leaves(key_val.last)
    end
  end

  def next_filename(prefix='report')
    filename, counter = nil, 0
    while filename.nil? or File.exist?(filename)
      counter += 1
      filename = File.join(Rails.root, 'public', 'system', 'reports',
                           "#{@project.permalink}_#{prefix}_%06d.json" % counter)
    end
    filename
  end

  def set_project!
    @project = Project.find_by_api_key(params[:api_key])
    raise "No project with api key #{params[:api_key]} found." if @project.nil?
  end  

end
