FactoryGirl.define do
  factory :default_user, class: User do
    email { "#{Faker::Name.first_name}.#{Faker::Name.last_name}@mail.com".downcase }
    password '123456'
    password_confirmation '123456'

    factory :grouped_user do
      role 'user'
      group 'msk'
    end

  end
end