FactoryGirl.define do

  sequence :email do |n|
    "user#{n}@example.com"
  end
  sequence :choice_key do |n|
    "Jefferson Smith ORHD#{n}"
  end

  factory :user do
      email
      password "testactular"
  end
  factory :feedback do
    choice_key
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
end