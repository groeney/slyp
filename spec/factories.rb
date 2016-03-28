FactoryGirl.define do
  factory :friendship do
    association :user
    association :friend, factory: :user
  end

  factory :reslyp do
    user
    sender { true }
  end

  factory :user_slyp do
    user
    association :slyp

    trait :with_reslyp do
      after(:create) do |user_slyp|
        friend = FactoryGirl.create(:user)
        user_slyp.send_slyp(friend.email, "Reslyp comment from FactoryGirl.")
      end
    end
  end

  factory :slyp do
    sequence(:url) { |n| "https://test_url#{n}.com" }
  end

  factory :user do
    sequence(:email) { |n| "#{first_name}.#{last_name}_#{n}@example.com" }
    password { SecureRandom.hex(8) }
    first_name "Joe"
    last_name "Blogs"
    sequence(:user_name) { |n| "#{first_name}#{last_name}_#{n}" }

    trait :with_slyps do
      after(:create) do |user|
        user.slyps << FactoryGirl.create_list(:slyp, 10)
      end
    end

    trait :with_user_slyps do
      after(:create) do |user|
        user.user_slyps << FactoryGirl.create_list(:user_slyp, 10, user: user)
      end
    end

    trait :with_reslyps do
      after(:create) do |user|
        FactoryGirl.create_list(:user_slyp, 10, :with_reslyp, user: user)
      end
    end
  end
end
