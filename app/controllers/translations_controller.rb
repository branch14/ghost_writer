class TranslationsController < InheritedResources::Base

  respond_to :html, :json

  private

  def collection
    @translations ||= Translation.page(params[:page]).order('content')
    if params[:filter]
      @translations = @translations.where('content LIKE ?', "%#{params[:filter]}%").
        where(:locale_id => params[:locale_id])
    end
  end

end
