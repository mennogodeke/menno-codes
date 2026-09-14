Rails.application.routes.draw do
  resource :session, only: %i[ new create destroy ]

  # English is the default and stays unprefixed (/, /about) — only nl/de get
  # a locale prefix, so there's never a duplicate /en URL for the same page.
  scope "(:locale)", locale: /nl|de/ do
    root "pages#home"
    get "about", to: "pages#about"
  end

  get "cv", to: "pages#cv"
  resources :users

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
