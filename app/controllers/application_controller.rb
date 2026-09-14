class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # Only routes inside the (:locale) scope (config/routes.rb) ever carry a
  # :locale param — everything else (session, /cv, /users) has none, so this
  # just falls back to the default locale for them. Deliberately not set via
  # default_url_options: that's global to every url_for call in the app and
  # would leak a stray ?locale= query param onto those non-scoped routes.
  around_action :set_locale

  private
    def set_locale(&action)
      I18n.with_locale(params[:locale].presence || I18n.default_locale, &action)
    end
end
