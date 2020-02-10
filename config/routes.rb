Rails.application.routes.draw do
  # API endpoints
  scope :api do
    put "/sessions/token", to: "sessions#refresh", as: "refresh"
    delete "/sessions/token", to: "sessions#destroy", as: "logout"

    resources :users, except: [:index]
    get "/users/:id/tables", to: "users#tables", as: "users-tables"

    resources :tables
    get "/numbered-tables/:num", to: "tables#show", as: "numbered-table"
  end

  # other
  get "/login/:provider", to: "sessions#login"
  get "/auth/:provider/callback", to: "sessions#create"
  get "/auth/failure", to: "sessions#failure"
end
