# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :member do
    role "MyString"
    startup nil
    user nil
  end
end
