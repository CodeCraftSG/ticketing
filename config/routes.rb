Rails.application.routes.draw do
  get 'orders/express_checkout'

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  root 'ticketings#index'
  resources :ticketings, only: [] do
    collection do
      get '/review_order', to: 'ticketings#review_order'
    end
  end
  resources :orders, only: [] do
    collection do
      post '/express_checkout', to: 'orders#express_checkout'
    end
  end
end
