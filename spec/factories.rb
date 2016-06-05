FactoryGirl.define do
  factory :reply do
    reslyp
    sender { reslyp.recipient }
    text "This is a reply from FactoryGirl"
  end

  factory :beta_request do
    sequence(:email) { |n| "beta_request_#{n}@example.com" }
  end

  factory :friendship do
    user
    friend
  end

  factory :reslyp do
    slyp
    sender_user_slyp
    recipient_user_slyp
    sender { sender_user_slyp.user }
    recipient { recipient_user_slyp.user }
    comment "Basic lazy comment from FactoryGirl"

    trait :with_replies do
      after(:create) do |reslyp|
        5.times do |i|
          FactoryGirl.create(:reply, sender: reslyp.sender, reslyp: reslyp,
            text: "Reply from sender ##{i}")
        end

        5.times do |i|
          FactoryGirl.create(:reply, sender: reslyp.recipient, reslyp: reslyp,
            text: "Reply from recipient ##{i}")
        end
      end
    end
  end

  factory :user_slyp, aliases: [:sender_user_slyp, :recipient_user_slyp] do
    user
    slyp

    trait :with_reslyp do
      after(:create) do |user_slyp|
        reslyp = FactoryGirl.create(:reslyp, sender: user_slyp.user, sender_user_slyp: user_slyp)
      end
    end

    trait :with_reslyp_and_replies do
      after(:create) do |user_slyp|
        reslyp = FactoryGirl.create(:reslyp, :with_replies, sender: user_slyp.user, sender_user_slyp: user_slyp)
      end
    end
  end

  factory :slyp do
    sequence(:url) { |n| "https://test_url#{n}.com" }
  end

  factory :user, aliases: [:recipient, :sender, :friend] do
    sequence(:email) { |n| "#{first_name}.#{last_name}_#{n}@example.com" }
    password { SecureRandom.hex(8) }
    authentication_token { Devise.friendly_token }
    first_name "Joe"
    last_name "Blogs"
    sequence(:user_name) { |n| "#{first_name}#{last_name}_#{n}" }

    trait :with_friends do
      after(:create) do |user|
        prospects = FactoryGirl.create_list(:user, 10)
        prospects.each do |prospect|
          user.befriend(prospect.id)
        end
      end
    end

    trait :with_slyps do
      after(:create) do |user|
        user.slyps << FactoryGirl.create_list(:slyp, 10)
      end
    end

    trait :with_user_slyps do
      after(:create) do |user|
        FactoryGirl.create_list(:user_slyp, 10, user: user)
      end
    end

    trait :with_reslyps do
      after(:create) do |user|
        FactoryGirl.create_list(:user_slyp, 10, :with_reslyp, user: user)
      end
    end

    trait :with_reslyps_and_replies do
      after(:create) do |user|
        FactoryGirl.create_list(:user_slyp, 10, :with_reslyp_and_replies, user: user)
      end
    end
  end
end
