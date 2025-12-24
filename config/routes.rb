Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  resources :tasks
  root "tasks#index"

  # 註冊功能
  # 我們只需要 new (顯示表單) 和 create (送出表單)
  # 使用 'signup' 作為路徑名稱比較直覺
  get "/signup", to: "users#new"
  post "/users", to: "users#create"

  # 登入/登出功能
  # 登入是一個「建立 session」的動作，登出是「刪除 session」
  get "/login", to: "sessions#new"
  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"
end
