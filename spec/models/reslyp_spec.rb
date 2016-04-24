require "rails_helper"

RSpec.describe Reslyp, type: :model do
  context "associations" do
    it { is_expected.to belong_to :user_slyp }
    it { is_expected.to belong_to :user }
  end

  context "validations and valid reslyps" do
    let(:user) { FactoryGirl.create(:user, :with_user_slyps) }
    let(:recipient) { FactoryGirl.create(:user) }
    let(:user_slyp) { user.user_slyps.first }
    let(:reslyps) { user_slyp.send_slyps([recipient.email], "Dummy comment")[0] }
    let(:sent_reslyp) { reslyps[:sent_reslyp] }
    let(:received_reslyp) { reslyps[:received_reslyp] }

    it "should validate initial reslyps" do
      expect(received_reslyp.valid?).to be true
      expect(sent_reslyp.valid?).to be true
    end

    it "should enforce uniqueness of user_slyp scoped to user" do
      reslyps = user_slyp.send_slyps([recipient.email], "Dummy comment")
      expect(received_reslyp.valid?).to be false
      expect(sent_reslyp.valid?).to be false
    end

    it "should enforce correct sibling associations" do
      expect(received_reslyp.sibling).to eq(sent_reslyp)
      expect(sent_reslyp.sibling).to eq(received_reslyp)
    end

    it "should notify the recipient" do
      perform_enqueued_jobs do
        email = "dummy_test_email@example.com"
        comment = "Another dummy comment"
        user_slyp.send_slyps([email], comment)

        delivered_email = ActionMailer::Base.deliveries.last
        expect(delivered_email.to.first).to eq email
        expect(delivered_email.from.first).to eq "#{user.email}"
        expect(delivered_email.subject).to eq "reslyp :)"

        expect(delivered_email.text_part.body.decoded).to include comment
        expect(delivered_email.text_part.body.decoded).to include user_slyp.slyp.url
        expect(delivered_email.html_part.body.decoded).to include comment
        expect(delivered_email.html_part.body.decoded).to include user_slyp.slyp.url
      end
    end
  end
end
