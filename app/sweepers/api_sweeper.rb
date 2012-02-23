class ApiSweeper < ActionController::Caching::Sweeper

  observe Translation

  def after_create(translation)
    expire_cache_for(translation)
  end
 
  def after_update(translation)
    expire_cache_for(translation)
  end
  
  def after_destroy(translation)
    expire_cache_for(translation)
  end
  
  private

  def expire_cache_for(translation)
    id = translation.token.project_id
    logger.debug "expiring cache for project #{id}"
    expire_page :controller => 'api', :action => 'single_post', :project_id => project_id
  end

end
