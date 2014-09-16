OpenBallot::Application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }

  match '/users/cancel' => 'user#cancel', :as => 'user_cancel', :via => :get
  match '/users/update' => 'user#update', :as => 'user_update', :via => :post
  match '/users/pages' => 'user#access_pages', :as => 'user_pages', :via => :get
  match '/users/pages/:fb' => 'user#page_session', :as => 'user_page_session_create', :via => :get
  match '/users/auth/:provider/callback' => 'authentications#create', :via => :get

  match '/:type/add' => 'choice#new', :via => :get, :type => /candidate|measure/ , :as => 'user_add_choice'
  match '/add' => 'choice#create', :via => :post, :as => 'user_create_choice'

  scope '/admin' do
    match '' => 'admin#index', :as => 'admin', :via => :get

    match '/find/:object/' => 'admin#find', :as => 'admin_find', :via => :post
    match '/:id' => 'admin#admin', :as => 'user_admin', :via => :post
    match '/ban/:id' => 'admin#ban', :as => 'user_ban', :via => :post
    match '/choice/:id' => 'admin#choice_edit', :as => 'choice_edit', :via => :get
    match '/choice/:id' => 'admin#choice_update', :as => 'choice_update', :via => :post
    match '/choice/:id/delete' => 'admin#choice_delete', :as => 'choice_delete', :via => :post
    match '/option/:id/delete' => 'admin#option_delete', :as => 'option_delete', :via => :post

    scope '/districts' do
      match '' => 'districts#index', :as => 'districts', :via => :get
      match '/add' => 'districts#new', :via => :get
      match '/add' => 'districts#create', :via => :post
    end
  end

  root :to => "home#index"
  match '/about' => "home#about", :via => :get
  match '/about/privacy' => "home#privacy", :as => 'privacy', :via => :get
  match '/about/terms' => "home#tos", :as => 'terms', :via => :get
  match '/stats' => "home#stats", :via => :get
  match '/search' => "home#search", :as => 'search', :via => :get
  match '/how-to' => redirect('https://docs.google.com/document/d/1U7kY9aU_e89GYb9oDt5ilzpjkzsCFtwUQNCr2AK9MAM/edit'), :via => :get
  match '/resources/how-to' => redirect('https://docs.google.com/document/d/1U7kY9aU_e89GYb9oDt5ilzpjkzsCFtwUQNCr2AK9MAM/edit'), :via => :get
  match '/source' => redirect('https://github.com/BusProject/Ballot'), :via => :get
  match '/sitemap' => 'home#sitemap', :as => 'sitemap', :via => :get

  match '/lookup' => 'choice#index', :via => :get
  match '/lookup/:id/more' => 'choice#more', :via => :get

  match '/:state' => 'choice#state', :state =>/AL|AK|AZ|AR|CA|CO|CT|DE|FL|GA|HI|ID|IL|IN|IA|KS|KY|LA|ME|MD|MA|MI|MN|MS|MO|MT|NE|NV|NH|NJ|NM|NY|NC|ND|OH|OK|OR|PA|RI|SC|SD|TN|TX|UT|VT|VA|WA|WV|WI|WY|DC/ , :as => 'state', :via => :get
  match '/:geography/:contest' => 'choice#show', :contest =>/[^\/]+/ , :as => 'contest', :via => :get
  match '/:geography/:contest/edit' => 'choice#edit', :contest =>/[^\/]+/ , :as => 'edit_contest', :via => :get


  match '/:id' => 'choice#profile', :as => 'profile', :via => :get
  match '/:id/past' => 'choice#profile', :as => 'profile_all', :via => :get, :past => true

end
