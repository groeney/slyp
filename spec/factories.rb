FactoryGirl.define do
  factory :reslyp do

  end
  factory :user_slyp do

  end
  factory :slyp do

  end
  factory :user do
    sequence(:email) { |n| "test_email#{n}@example.com" }
    password { SecureRandom.hex(8) }
  end
end
