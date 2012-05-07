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

end