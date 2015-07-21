Rails.application.routes.draw do
  get 'orders/express_checkout'

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  root 'ticketings#index'
  resources :ticketings, only: [:index] do
    collection do
      get '/review_order', to: 'ticketings#review_order'
    end
  end
  resources :orders, only: [:show] do
    collection do
      post '/express_checkout', to: 'orders#express_checkout'
    end

    member do
      get '/success', to: 'orders#success'
      get '/cancel', to: 'orders#cancel'
      get '/attendees', to: 'orders#attendee_particulars'
      post '/attendees', to: 'orders#update_attendee_particulars'
      get '/completed', to: 'orders#completed'
    end
  end
end
