FactoryGirl.define do
  factory :task do
    title { Faker::Lorem.sentence(3, '', 0) }
  end
end