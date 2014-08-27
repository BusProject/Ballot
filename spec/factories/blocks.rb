# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :block do
    guide nil
    option nil
    user_option nil
    title "MyString"
    content "MyText"
  end
end
