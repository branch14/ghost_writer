class TranslationsController < InheritedResources::Base

  respond_to :html, :json

  private

  def collection
    @translations ||= Translation.order('hits DESC').
      includes(:token).where(:locale_id => params[:locale_id])
    if params[:filter]
      @translations = @translations.
        where('content LIKE ? or tokens.raw LIKE ?', 
              "%#{params[:filter]}%", "%#{params[:filter]}%")
    end
  end

end
