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
  match '/users/auth/:provider/callback' => 'authentications#create'

  match '/users/add/:type' => 'choice#new', :via => :get, :type => /candidate|measure/ , :as => 'user_add_choice'
  match '/users/add' => 'choice#create', :via => :post, :as => 'user_create_choice'

  match '/admin' => 'admin#index', :as => 'admin'
  match '/admin/find/:object/' => 'admin#find', :as => 'admin_find' #, :via => :post
  match '/admin/:id' => 'admin#admin', :as => 'user_admin', :via => :post
  match '/admin/ban/:id' => 'admin#ban', :as => 'user_ban', :via => :post
  match '/admin/choice/:id' => 'admin#choice_edit', :as => 'choice_edit', :via => :get
  match '/admin/choice/:id' => 'admin#choice_update', :as => 'choice_update', :via => :post
  match '/admin/feedback/:id' => 'admin#feedback', :as => 'approval_feedback' #, :via => :post


  
  root :to => "home#index"
  match '/about' => "home#about"
  match '/stats' => "home#stats"
  match '/search' => "home#search", :as => 'search'
  match '/how-to' => redirect('https://docs.google.com/document/d/1U7kY9aU_e89GYb9oDt5ilzpjkzsCFtwUQNCr2AK9MAM/edit')
  match '/source' => redirect('https://github.com/BusProject/Ballot')
  match '/sitemap' => 'home#sitemap', :as => 'sitemap'

  match '/lookup' => 'choice#index'
  match '/lookup/:id/more' => 'choice#more'
  
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

end
