Ballot::Application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }, skip: :registrations
  devise_scope :user do
    resource :registration,
      only: [:new, :create ], path: 'users', path_names: { new: 'sign_up' }, controller: 'devise/registrations'
  end

  match '/users/cancel' => 'user#cancel', :as => 'user_cancel'
  match '/users/update' => 'user#update', :as => 'user_update', :via => :post
  match '/users/pages' => 'user#access_pages', :as => 'user_pages'
  match '/users/login' => 'user#login', :as => 'user_login'
  match '/users/forgot_password' => 'user#forgot_password', :as => 'user_forgot_password'
  match '/users/signup' => 'user#signup', :as => 'user_signup', :as => 'user_signup', :via => :post
  match '/users/signin' => 'user#signin', :as => 'user_signin', :as => 'user_signin', :via => :post
  match '/users/pages/:fb' => 'user#page_session', :as => 'user_page_session_create'
  match '/users/auth/:provider/callback' => 'authentications#create'

  match '/users/add/:type' => 'choice#new', :via => :get, :type => /candidate|measure/ , :as => 'user_add_choice'
  match '/users/add' => 'choice#create', :via => :post, :as => 'user_create_choice'

  match '/guide/create' => 'guide#create', :as => 'guide_create', :via => :post
  match '/guide/:id/edit' => 'guide#edit', :as => 'guide_edit'
  match '/guide/:id/update' => 'guide#update', :as => 'guide_update', :via => :post
  match '/guide/:id/delete' => 'guide#destroy', :as => 'guide_delete', :via => :post
  match '/block/new' => 'block#new', :as => 'block_new'
  match '/block/create' => 'block#create', :as => 'block_create', :via => :post
  match '/block/:id/half' => 'block#half', :as => 'block_half', :via => :post
  match '/block/:id/edit' => 'block#edit', :as => 'block_edit'
  match '/block/:id/update' => 'block#update', :as => 'block_update', :via => :post
  match '/block/:id/delete' => 'block#destroy', :as => 'block_delete', :via => :post


  scope '/admin' do
    match '' => 'admin#index', :as => 'admin'

    match '/find/:object/' => 'admin#find', :as => 'admin_find' #, :via => :post
    match '/:id' => 'admin#admin', :as => 'user_admin', :via => :post
    match '/ban/:id' => 'admin#ban', :as => 'user_ban', :via => :post
    match '/choice/:id' => 'admin#choice_edit', :as => 'choice_edit', :via => :get
    match '/choice/:id' => 'admin#choice_update', :as => 'choice_update', :via => :post
    match '/choice/:id/delete' => 'admin#choice_delete', :as => 'choice_delete', :via => :post
    match '/option/:id/delete' => 'admin#option_delete', :as => 'option_delete', :via => :post
    match '/feedback/:id' => 'admin#feedback', :as => 'approval_feedback' #, :via => :post

    match '/import/candidates' => 'admin#import_candidates', :as => 'import_candidates'
    match '/import/measures' => 'admin#import_measures', :as => 'import_measures'

  end


  root :to => "home#index"
  match '/about' => "home#about"
  match '/about/privacy' => "home#privacy", :as => 'privacy'
  match '/about/terms' => "home#tos", :as => 'terms'
  match '/stats' => "home#stats"
  match '/search' => "home#search", :as => 'search'
  match '/how-to' => redirect('https://docs.google.com/document/d/1U7kY9aU_e89GYb9oDt5ilzpjkzsCFtwUQNCr2AK9MAM/edit')
  match '/resources/how-to' => redirect('https://docs.google.com/document/d/1U7kY9aU_e89GYb9oDt5ilzpjkzsCFtwUQNCr2AK9MAM/edit')
  match '/source' => redirect('https://github.com/BusProject/Ballot')
  match '/sitemap' => 'home#sitemap', :as => 'sitemap'

  match '/block/:state' => 'block#state', :as => 'state_guides'

  match '/friends' => 'choice#friends'
  match '/guides/top' =>  'home#guides', :as => 'top_guides'

  match '/lookup' => 'choice#index' #, :via => :post
  match '/lookup/:id/more' => 'choice#more'

  match '/feedback/save' => 'feedback#update', :via => :post, :as => 'save_feedback'
  match '/feedback/:id/remove' => 'feedback#delete', :via => :post, :as => 'remove_feedback'
  match '/feedback/:id/flag' => 'feedback#flag', :via => :post, :as => 'flag_feedback'
  match '/feedback/:id/:flavor' => 'feedback#vote', :via => :post, :as => 'rate_feedback'
  match '/feedback/:id' => 'feedback#show', :as => 'show_feedback'

  match '/:state' => 'choice#state', :state =>/AL|AK|AZ|AR|CA|CO|CT|DE|FL|GA|HI|ID|IL|IN|IA|KS|KY|LA|ME|MD|MA|MI|MN|MS|MO|MT|NE|NV|NH|NJ|NM|NY|NC|ND|OH|OK|OR|PA|RI|SC|SD|TN|TX|UT|VT|VA|WA|WV|WI|WY|DC/ , :as => 'state'

  match '/profile/:profile' => 'choice#profile', :as => 'profile', :via => :get
  match '/profile/:profile' => 'feedback#recommend', :as => 'recommend', :via => :post

  match '/:geography/:contest' => 'choice#show', :contest =>/[^\/]+/ , :as => 'contest'

  match '/:id' => 'guide#show', :as => 'guide_show'

end
