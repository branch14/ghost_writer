class ApiController < ApplicationController

  before_filter :set_project!
  caches_page :single_post

  def single_get
    send_yaml
  end

  def single_post
    filename = next_filename
    File.open(filename, 'w') { |f| f.puts params[:miss] }
    @project.delay.handle_missed2!(:filename => filename)
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
    send_data @project.aggregated_translations2.to_yaml,
      :type => 'application/x-yaml', :filename => 'translations.yml'
  end

end
