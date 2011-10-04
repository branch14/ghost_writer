class ApiController < ApplicationController

  before_filter :set_project!
  skip_before_filter :authenticate_user!

  def single_get
    send_yaml
  end

  def single_post
    if params[:miss] and params[:miss].size > 2 # empty is {}
      filename = next_filename
      File.open(filename, 'w') { |f| f.puts params[:miss] }
      @project.delay.handle_missed!(:filename => filename)
    end
    send_yaml
  end

  private

  def next_filename
    filename, counter = nil, 0
    while filename.nil? or File.exist?(filename)
      counter += 1
      filename = File.join(Rails.root, 'public', "#{@project.permalink}_%04d.json" % counter)
    end
    filename
  end

  def set_project!
    # @project = Project.where(:id => params[:project_id]).
    #   includes(:locales, :tokens => :translations).first
    @project = Project.find(params[:project_id])
  end

  def send_yaml
    # read cache
    data = Rails.cache.read(@project.permalink)
    timestamp = request.env['If-Modified-Since']
    unless data.blank? or timestamp.blank? # merge changes
      tokens = @project.tokens.changed_after(timestamp)
      data = tokens.inject(data) do |result, token|
        result.deep_merge token.translations_as_nested_hash
      end
    else # fallback if no cache or no timestamp
      data = @project.aggregated_translations
    end
    # write cache
    Rails.cache.write(@project.permalink, data)
    # set last-modified header
    # see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.29
    # resp. http://www.w3.org/Protocols/rfc2616/rfc2616-sec3.html#sec3.3
    response.headers['Last-Modified'] = l(Time.now, :format => :http)
    # send data
    send_data(data.to_yaml, :type => 'application/x-yaml', :filename => 'translations.yml')
  end

end
