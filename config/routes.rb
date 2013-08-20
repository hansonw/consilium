Consilium::Application.routes.draw do
  root 'home#index'

  get 'home/index' => 'home#index'

  devise_for :users, :controllers => {:registrations => 'users/registrations'}

  resources :brokerages

  scope :api do
    resources :users, :controller => 'api/users'
    get 'users/:id/reset_password' => 'api/users#reset_password_valid'
    put 'users/:id/reset_password' => 'api/users#reset_password'

    resources :clients, :controller => 'api/clients'
    post 'clients/:id' => 'api/clients#create'

    resources :recent_clients, :controller => 'api/recent_clients'
    put 'recent_clients' => 'api/recent_clients#update'

    resources :documents, :controller => 'api/documents'
    get 'documents/client/:id' => 'api/documents#client'
    put 'documents' => 'api/documents#update'

    resources :client_changes, :controller => 'api/client_changes'

    resource :brokerage, :controller => 'api/brokerage'

    post 'auth/login' => 'api/auth#login'
    get 'auth/logout' => 'api/auth#logout'
  end

  scope :app do
    get '' => 'home#app', :as => 'app_root'

    get 'templates/:path.html' => 'app/templates#page', :constraints => { :path => /.+/ }, :as => 'app_templates_show'

    scope :templates do
      get '' => 'home#app', :as => 'app_templates'

      # Don't include "template" in these :as paths as it is overly verbose.

      scope :clients do
        get '' => 'home#app', :as => 'app_clients'
        get 'new' => 'home#app', :as => 'app_clients_new'
        get 'recent' => 'home#app', :as => 'app_clients_recent'
        get 'show/:clientId' => 'home#app', :as => 'app_clients_show'
        get 'edit/:clientId' => 'home#app', :as => 'app_clients_edit'
        get 'edit/:clientId/location/' => 'home#app', :as => 'app_clients_new_location'
        get 'edit/:clientId/location/:locationId' => 'home#app', :as => 'app_clients_edit_location'
        get 'notfound' => 'home#app', :as => 'app_clients_notfound'
      end

      scope :auth do
        get '' => 'home#app', :as => 'app_auth'
        get 'login' => 'home#app', :as => 'app_auth_login'
        get 'forbidden' => 'home#app', :as => 'app_auth_forbidden'
      end

      scope :brokerage do
        get 'index' => 'home#app', :as => 'app_brokerage'
      end

      scope :users do
        get 'reset_password' => 'home#app', :as => 'app_users_reset_password'
      end
    end
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
