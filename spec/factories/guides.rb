# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :guide do
    user nil
    name "MyString"
    publish false
  end
end
