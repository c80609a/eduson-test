Rails.application.routes.draw do
  resources :users do
    resources :assignments, only: [:update, :destroy]
  end
  devise_for :users
  match 'assignments/to_users', to: 'assignments#to_users', via: :post
  match 'assignments/to_groups', to: 'assignments#to_groups', via: :post
end
