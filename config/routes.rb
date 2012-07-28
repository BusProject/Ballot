Ballot::Application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }

  
  root :to => "home#index"

  match '/auth/:provider/callback' => 'authentications#create'
  match '/lookup' => 'choice#index'
  match '/fetch' => 'choice#retrieve'
  
  match '/feedback/save' => 'feedback#update', :via => :post, :as => 'save_feedback'
  match '/feedback/:id/remove' => 'feedback#delete', :via => :post, :as => 'remove_feedback'
  match '/feedback/:id/:flavor' => 'feedback#rate', :via => :post, :as => 'rate_feedback'

  match '/m/:id/new' => 'meme#new', :via => :get, :as => 'meme_new'
  match '/m/:id/new' => 'meme#new', :via => :post, :as => 'meme_create'
  match '/m/:id/preview' => 'meme#show', :via => :post, :as => 'meme_preview'
  match '/m/:id' => 'meme#show', :via => :get, :as => 'meme_show'

  match '/:geography/:contest' => 'choice#show', :as => 'contest'
  
  match '/:id' => 'choice#profile', :as => 'profile'

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
