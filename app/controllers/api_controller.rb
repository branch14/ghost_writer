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
        logger.debug "created token for #{key}"
        token.translations.each do |translation|
          logger.debug "adjusting translation for #{translation.locale.code}"
          attrs = { :hits => val['count'][translation.locale.code] }
          content = val['default'][translation.locale.code] unless val['default'].nil?
          content = val[:default][translation.locale.code] unless val[:default].nil?
          content ||= key
          attrs[:content] = content unless content.nil?
          logger.debug "content: #{attrs[:content]}"
          logger.debug "hits:    #{attrs[:hits]}"
          logger.debug "attrs:   #{attrs.inspect}"
          translation.reload
          #translation.update_attributes attrs
          #logger.debug("VE:"+translation.errors.full_messages) unless translation.valid?
          #translation.attributes.merge! attrs
          translation.content = content
          translation.hits = val['count'][translation.locale.code]
          logger.debug(translation.attributes.inspect)
          logger.debug("translation valid: #{translation.valid?}")
          logger.debug("token valid: #{translation.token.valid?}")
          logger.debug("locale valid: #{translation.locale.valid?}")
          logger.debug(translation.errors.full_messages)
          translation.save!
          raise 'something went wrong' unless translation.content == content
          logger.debug "SAVED"
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

end
