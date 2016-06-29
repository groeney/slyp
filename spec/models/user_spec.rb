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
  it "should send new user welcome email" do
    perform_enqueued_jobs do
      user = FactoryGirl.create(:user)
      delivered_email = ActionMailer::Base.deliveries.first
      assert_includes delivered_email.to, user.email
      assert_includes delivered_email.from, "james@slyp.io"
      assert_includes delivered_email.subject, "welcome to slyp beta :)"
    end
  end
  it "should send new friend notification to support" do
    perform_enqueued_jobs do
      user = FactoryGirl.create(:user)
      delivered_email = ActionMailer::Base.deliveries.last
      assert_includes delivered_email.to, User.support_user.email
      assert_includes delivered_email.subject, "#{user.display_name} joined you on Slyp"
    end
  end
  it "should ensure user is friends with support user" do
    user = FactoryGirl.create(:user)
    expect(user.friends? User.support_user.id).to be true
  end
end
