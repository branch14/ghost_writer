class TranslationsController < InheritedResources::Base

  respond_to :html, :json

  private

  def collection
    @translations ||= Translation.order('miss_counter DESC').
      includes(:token).where(:locale_id => params[:locale_id])
    if params[:filter]
      @translations = @translations.
        where("content #{like} ? OR tokens.raw #{like} ?",
              "%#{params[:filter]}%", "%#{params[:filter]}%")
    end
  end

  def like
    case ActiveRecord::Base.configurations[Rails.env]['adapter']
    when 'pg' then 'ILIKE'
    else
      'LIKE'
    end
  end

end
