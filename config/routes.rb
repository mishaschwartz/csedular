Rails.application.routes.draw do
  root controller: 'users', action: 'show'
  resources :locations
  resources :resources do
    resources :availabilities, except: [:edit]
    member do
      get 'current'
    end
  end
  resources :availabilities, only: [] do
    collection do
      get 'all'
    end
  end
  resources :bookings, only: [:create, :destroy, :index] do
    collection do
      get 'help'
    end
  end
  resources :users do
    member do
      put 'update_permissions'
    end
    collection do
      get 'login'
      post 'login'
      post 'logout'
      post 'reset_api_key'
    end
  end
end
