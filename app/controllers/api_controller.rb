class ApiController < ApplicationController

  before_filter :set_project!

  def single_get
    send_yaml!
  end

  def single_post
    #hits, miss = JSON.parse(params[:hits]), JSON.parse(params[:miss])
    #logger.debug miss.to_yaml
    @missed = JSON.parse(params[:miss])
    handle_missed!
    send_yaml!
  end

  def simple
    token   = @project.tokens.find_or_create_by_raw(params[:token_raw])
    locale  = @project.locales.find_by_code(params[:locale_code])
    translation = token.translations.find_by_locale_id(locale.id)
    render :text => translation.content || token.raw, :content_type => 'text/plain'
  end
 
  protected

  def handle_missed!
    File.open(File.join(Rails.root, 'public', "#{Time.now.to_i}.yml"), 'w') { |f| f.puts @missed.to_yaml }
    @missed.each do |key, val|
      token = @project.tokens.where(:raw => key).first
      if token.nil?
        token = @project.tokens.create(:raw => key)
        puts "created token for #{key}"
        token.translations.each do |translation|
          puts "adjusting translation for #{translation.locale.code}"
          attrs = { :hits => val['count'][translation.locale.code] }
          content = val['default'][translation.locale.code] unless val['default'].nil?
          content = val[:default][translation.locale.code] unless val[:default].nil?
          attrs[:content] = content unless content.nil?
          puts "content: #{attrs[:content]}"
          puts "hits:    #{attrs[:hits]}"
          puts "attrs:   #{attrs.inspect}"
          translation.update_attributes attrs
        end
      end
    end
  end

  def set_project!
    @project = Project.where(:id => params[:project_id]).
      includes(:locales, :tokens => :translations ).first
  end

  def send_yaml!
    send_data @project.aggregated_translations.to_yaml,
      :type => 'application/x-yaml', :filename => 'translations.yml'
  end

  def sample
    { 'en' => { 'this' => { 'is' => { 'a' => { 'test' => "Hello World" }}}}}.to_yaml
  end

end
