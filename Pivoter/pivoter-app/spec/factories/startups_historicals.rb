# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :startups_historical do
    name "MyString"
    webpage "MyString"
    description "MyText"
    videopitch "MyString"
    achievements "MyString"
    logo "MyString"
    user_id 1
    country "MyString"
    status "MyString"
    category "MyString"
    stage "MyString"
    pivot_counter 1
    audit_action "MyString"
    audit_date "2014-08-03"
  end
end
