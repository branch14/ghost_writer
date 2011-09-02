class ApiController < ApplicationController

  before_filter :set_project!

  def single_get
    send_yaml
  end

  def single_post
    filename = next_filename
    File.open(filename, 'w') { |f| f.puts params[:miss] }
    @project.delay.handle_missed!(:filename => filename)
    send_yaml
  end

  # def simple
  #   token   = @project.tokens.find_or_create_by_raw(params[:token_raw])
  #   locale  = @project.locales.find_by_code(params[:locale_code])
  #   translation = token.translations.find_by_locale_id(locale.id)
  #   render :text => translation.content || token.raw, :content_type => 'text/plain'
  # end
 
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
    @project = Project.where(:id => params[:project_id]).
      includes(:locales, :tokens => :translations).first
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
    response.headers['Last-Modified'] = Time.now
    # send data
    send_data data.to_yaml, :type => 'application/x-yaml', :filename => 'translations.yml'
  end

end
