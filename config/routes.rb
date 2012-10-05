Ballot::Application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }, skip: :registrations
  devise_scope :user do
    resource :registration,
      only: [:new, :create ], path: 'users', path_names: { new: 'sign_up' }, controller: 'devise/registrations'
  end
  
  match '/users/cancel' => 'user#cancel', :as => 'user_cancel'
  match '/users/update' => 'user#update', :as => 'user_update', :via => :post
  match '/users/pages' => 'user#access_pages', :as => 'user_pages'
  match '/users/pages/:fb' => 'user#page_session', :as => 'user_page_session_create'

  match '/admin' => 'admin#index', :as => 'admin'
  match '/admin/find/:object/' => 'admin#find', :as => 'admin_find' #, :via => :post
  match '/admin/:id' => 'admin#admin', :as => 'user_admin', :via => :post
  match '/admin/ban/:id' => 'admin#ban', :as => 'user_ban', :via => :post
  match '/admin/choice/:id' => 'admin#choice_edit', :as => 'choice_edit', :via => :get
  match '/admin/choice/:id' => 'admin#choice_update', :as => 'choice_update', :via => :post
  match '/admin/feedback/:id' => 'admin#feedback', :as => 'approval_feedback' #, :via => :post

  
  root :to => "home#index"
  match '/about' => "home#about"
  match '/about/privacy' => "home#privacy", :as => 'privacy'
  match '/about/terms' => "home#tos", :as => 'terms'
  match '/stats' => "home#stats"
  match '/search' => "home#search", :as => 'search'
  match '/how-to' => redirect('https://docs.google.com/document/d/1U7kY9aU_e89GYb9oDt5ilzpjkzsCFtwUQNCr2AK9MAM/edit')
  match '/source' => redirect('https://github.com/BusProject/Ballot')

  match '/auth/:provider/callback' => 'authentications#create'
  match '/lookup' => 'choice#index'
  match '/lookup/:id/more' => 'choice#more'
  match '/fetch' => 'choice#retrieve', :as => 'choices_fetch'
  
  match '/feedback/save' => 'feedback#update', :via => :post, :as => 'save_feedback'
  match '/feedback/:id/remove' => 'feedback#delete', :via => :post, :as => 'remove_feedback'
  match '/feedback/:id/flag' => 'feedback#flag', :via => :post, :as => 'flag_feedback'
  match '/feedback/:id/:flavor' => 'feedback#vote', :via => :post, :as => 'rate_feedback'

  match '/m/:id/new' => 'meme#new', :via => :get, :as => 'meme_new'
  match '/m/:id/new' => 'meme#update', :via => :post, :as => 'meme_create'
  match '/m/:id/preview' => 'meme#preview', :via => :post, :as => 'meme_preview'
  match '/m/:id/fb' => 'meme#fb', :via => :get, :as => 'meme_fb_image'
  match '/m/:id' => 'meme#show', :via => :get, :as => 'meme_show_image'
  match '/m/:id' => 'meme#destroy', :via => :post, :as => 'meme_show_image'


  match '/:state' => 'choice#state', :state =>/AL|AK|AZ|AR|CA|CO|CT|DE|FL|GA|HI|ID|IL|IN|IA|KS|KY|LA|ME|MD|MA|MI|MN|MS|MO|MT|NE|NV|NH|NJ|NM|NY|NC|ND|OH|OK|OR|PA|RI|SC|SD|TN|TX|UT|VT|VA|WA|WV|WI|WY|DC/ , :as => 'state'

  match '/:geography/:contest' => 'choice#show', :contest =>/[^\/]+/ , :as => 'contest'
  
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
