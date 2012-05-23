FactoryGirl.define do

  sequence :email do |n|
    "user#{n}@example.com"
  end  
  

  factory :user do
      email
      password "testactular"
  end
  factory :feedback do
    user_id { 1 + rand(100) }
  end

  sequence :geography do |n|
    "ORHD#{n}"
  end
  sequence :contest do |n|
    "Mayor of #{n}"
  end

  factory :choice do
    geography
    contest
    contest_type 'candidate'
    description 'Now this is the story all about how My life got flipped, turned upside down And I\'d like to take'
    order { 1 + rand(100) }
  end

  sequence :name do |n|
    "Willy Wonka the #{n}"
  end

  factory :option do
    name
    choice
    photo 'http://electrokami.com/wp-content/uploads/2011/01/steve-carell-the-office.jpg'
    blurb 'Now this is the story all about how My life got flipped, turned upside down And I\'d like to take'
    position { 1 + rand(100) }
  end


end