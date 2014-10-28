Nov::Application.routes.draw do

  root :to => "home#index"

  match '/about' => "home#about"
  match '/about/privacy' => "home#privacy", :as => 'privacy'
  match '/about/terms' => "home#tos", :as => 'terms'
  match '/search' => "home#search", :as => 'search'
  match '/how-to' => redirect('https://docs.google.com/document/d/1U7kY9aU_e89GYb9oDt5ilzpjkzsCFtwUQNCr2AK9MAM/edit')
  match '/resources/how-to' => redirect('https://docs.google.com/document/d/1U7kY9aU_e89GYb9oDt5ilzpjkzsCFtwUQNCr2AK9MAM/edit')
  match '/source' => redirect('https://github.com/BusProject/Ballot')
  match '/sitemap' => 'home#sitemap', :as => 'sitemap'

  match '/guides/top' =>  'home#guides', :as => 'top_guides'

  match '/lookup' => 'choice#index' #, :via => :post
  match '/lookup/:id/more' => 'choice#more'

  match '/:state' => 'choice#state', :state =>/AL|AK|AZ|AR|CA|CO|CT|DE|FL|GA|HI|ID|IL|IN|IA|KS|KY|LA|ME|MD|MA|MI|MN|MS|MO|MT|NE|NV|NH|NJ|NM|NY|NC|ND|OH|OK|OR|PA|RI|SC|SD|TN|TX|UT|VT|VA|WA|WV|WI|WY|DC/ , :as => 'state'

  match '/profile/:profile' => 'choice#profile', :as => 'profile', :via => :get
  match '/profile/:profile' => 'feedback#recommend', :as => 'recommend', :via => :post

  match '/:geography/:contest' => 'choice#show', :contest =>/[^\/]+/ , :as => 'contest'

  match '/:id' => 'guide#show', :as => 'guide_show'

end
