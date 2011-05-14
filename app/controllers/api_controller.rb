class ApiController < ApplicationController

  def single_get
    project = Project.find(params[:project_id])
    send_data sample, :type => 'application/x-yaml', :filename => 'translations.yml'
  end

  def single_post
    project = Project.find(params[:project_id])
    hits_json, miss_json = params[:hits], params[:miss]
    send_data sample, :type => 'application/x-yaml', :filename => 'translations.yml'
  end

  def simple
    project = Project.find(params[:project_id])
    token   = project.tokens.find_or_create_by_raw(params[:token_raw])
    locale  = project.locales.find_by_code(params[:locale_code])
    translation = token.translations.find_by_locale_id(locale.id)
    render :text => translation.content || token.raw, :content_type => 'text/plain'
  end
 
  protected

  def sample
    { 'en' => { 'this' => { 'is' => { 'a' => { 'test' => "Hello World" }}}}}.to_yaml
  end

end
