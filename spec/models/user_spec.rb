require "rails_helper"

RSpec.describe User, type: :model do
  context "associations" do
    it { is_expected.to have_many :user_slyps }
    it { is_expected.to have_many :slyps }
    it { is_expected.to have_many :sent_reslyps }
    it { is_expected.to have_many :received_reslyps }
    it { is_expected.to have_many :friendships }
    it { is_expected.to have_many :friends }
  end
  describe "#create" do
    it "should send new user welcome email" do
      perform_enqueued_jobs do
        @user = FactoryGirl.create(:user)
        delivered_email = ActionMailer::Base.deliveries.last

        assert_includes delivered_email.to, @user.email
        assert_includes delivered_email.from, "jamesgroeneveld@gmail.com"
        assert_includes delivered_email.subject, "welcome to slyp beta :)"
      end
    end
  end
end
