require "rails_helper"

RSpec.describe BetaRequest, type: :model do
  context "validations" do
    subject { FactoryGirl.create(:beta_request) }
    it { should validate_uniqueness_of(:email).with_message("has already been submitted.") }
  end
  context "create" do
    it "it should send email" do
      perform_enqueued_jobs do
        @beta_request = FactoryGirl.create(:beta_request)
        delivered_email = ActionMailer::Base.deliveries.last

        assert_includes delivered_email.to, @beta_request.email
        assert_includes delivered_email.from, "robot@slyp.io"
        assert_includes delivered_email.subject, "waiting for slyp beta"
      end
    end
  end
end
