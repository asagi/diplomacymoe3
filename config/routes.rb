Rails.application.routes.draw do
  get "/login/:provider", to: "sessions#login"
  get "/auth/:provider/callback", to: "sessions#create"
  get "/auth/failure", to: "sessions#failure"
  get "/refresh", to: "sessions#refresh"
  get "/logout", to: "sessions#destroy"

  resources :users, except: [:index]
  resources :tables
  get "/numbered-tables/:num", to: "tables#show"
end
