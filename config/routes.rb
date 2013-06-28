Consilium::Application.routes.draw do
  root 'home#index'

  get 'home/index' => 'home#index'

  devise_for :users

  scope :api do
    resources :clients, :controller => 'api/clients'
    resources :documents, :controller => 'api/documents'
    put 'documents' => 'api/documents#update'
    post 'auth/login' => 'api/auth#login'
    post 'auth/logout' => 'api/auth#logout'
  end

  scope :app do
    get '' => 'home#app', :as => 'app_root'

    get 'templates/:path.html' => 'app/templates#page', :constraints => { :path => /.+/ }, :as => 'app_templates_show'

    scope :templates do
      get '' => 'home#app', :as => 'app_templates_root'

      # Don't include "template" in these :as paths as it is overly verbose.

      scope :clients do
        get '' => 'home#app', :as => 'app_clients'
        get 'new' => 'home#app', :as => 'app_clients_new'
        get 'recent' => 'home#app', :as => 'app_clients_recent'
        get 'show/:clientId' => 'home#app', :as => 'app_clients_show'
        get 'edit/:clientId' => 'home#app', :as => 'app_clients_edit'
      end

      scope :auth do
        get '' => 'home#app', :as => 'app_auth'
        get 'login' => 'home#app', :as => 'app_auth_login'
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
