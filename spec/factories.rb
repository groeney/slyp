FactoryGirl.define do
  factory :friendship do
    association :user
    association :friend
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
        to_user_slyp = friend.user_slyps.find_or_create_by({
          :slyp_id => user_slyp.slyp_id
          })
        sent_reslyp = Reslyp.send_reslyp(to_user_slyp, user_slyp)
        received_reslyp = sent_reslyp.receive_reslyp("Reslyp comment from FactoryGirl.")
      end
    end
  end

  factory :slyp do
    sequence(:url) { |n| "https://test_url#{n}.com" }
  end

  factory :user do
    sequence(:email) { |n| "test_email_#{n}@example.com" }
    password { SecureRandom.hex(8) }

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
