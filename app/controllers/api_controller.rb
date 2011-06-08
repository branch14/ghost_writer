

class ApiController < ApplicationController

  before_filter :set_project!
  caches_page :single_post

  def single_get
    send_yaml
  end

  def single_post
    filename = File.join(Rails.root, 'public', "#{@project.permalink}_#{Time.now.to_i}.json")
    File.open(filename, 'w') { |f| f.puts params[:miss] }
    @project.delay.handle_missed!(filename)
    send_yaml
  end

  def simple
    token   = @project.tokens.find_or_create_by_raw(params[:token_raw])
    locale  = @project.locales.find_by_code(params[:locale_code])
    translation = token.translations.find_by_locale_id(locale.id)
    render :text => translation.content || token.raw, :content_type => 'text/plain'
  end
 
  protected

  def set_project!
    @project = Project.where(:id => params[:project_id]).
      includes(:locales, :tokens => :translations).first
  end

  def send_yaml
    send_data @project.aggregated_translations.to_yaml,
      :type => 'application/x-yaml', :filename => 'translations.yml'
  end

end
