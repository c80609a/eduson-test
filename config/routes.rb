Rails.application.routes.draw do
  resources :users do
    resources :assignments
  end
  devise_for :users
end
