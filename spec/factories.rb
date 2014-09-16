FactoryGirl.define do

  sequence :email do |n|
    "user#{n}@example.com"
  end
  factory :user do
      email
      password "testactular"
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
    factory :option_with_feedback do
      ignore do
        feedback_count 3
      end

      after_create do |option,evaluator|
        FactoryGirl.create_list(:feedback, evaluator.feedback_count, :option => option )
      end
    end
  end

  factory :feedback do
    option
    comment 'Yo this dude SUCKS'
    support true
    user
  end


end