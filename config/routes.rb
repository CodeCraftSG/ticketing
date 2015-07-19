Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  root 'ticketings#index'
  resources :ticketings, only: [] do
    collection do
      get '/review_order', to: 'ticketings#review_order'
    end
  end
end
