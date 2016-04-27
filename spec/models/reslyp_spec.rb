require "rails_helper"

RSpec.describe Reslyp, type: :model do
  context "associations" do
    it { is_expected.to belong_to :recipient }
    it { is_expected.to belong_to :sender }
    it { is_expected.to belong_to :recipient_user_slyp }
    it { is_expected.to belong_to :sender_user_slyp }
    it { is_expected.to belong_to :slyp }
    it { is_expected.to have_many :replies }
  end

  context "validations and valid reslyps" do
    let(:user) { FactoryGirl.create(:user, :with_user_slyps) }
    let(:recipient) { FactoryGirl.create(:user) }
    let(:user_slyp) { user.user_slyps.first }
    let(:reslyp) { user_slyp.send_slyp(recipient.email, "Dummy comment") }

    it "should validate reslyp" do
      expect(reslyp.valid?).to be true
    end

    it "should enforce uniqueness of recipient_user_slyp scoped to sender" do
      expect(reslyp.valid?).to be true
      second_reslyp = user_slyp.send_slyp(recipient.email, "Dummy comment")
      expect(second_reslyp.valid?).to be false
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

    it "should not send welcome email to new recipient" do
      perform_enqueued_jobs do
        email = "dummy_test_email+1@example.com"
        comment = "Another dummy comment"
        user_slyp.send_slyps([email], comment)

        ActionMailer::Base.deliveries.each do |delivered_email|
          if delivered_email.to.first == email
            expect(delivered_email.subject).not_to eq "welcome to slyp beta :)"
          end
        end
      end
    end
  end
  context "validations on invalid reslyps" do
    let(:user) { FactoryGirl.create(:user, :with_user_slyps) }
    let(:user_slyp) { user.user_slyps.first }
    let(:friend) { FactoryGirl.create(:user) }
    let(:friend_user_slyp) { FactoryGirl.create(:user_slyp, user: friend,
      slyp: user_slyp.slyp) }
    let(:reslyp_params) {{
        :sender_id              => user.id,
        :recipient_id           => friend.id,
        :sender_user_slyp_id    => user_slyp.id,
        :recipient_user_slyp_id => friend_user_slyp.id,
        :comment                => "This is a comment.",
        :slyp_id                => user_slyp.slyp.id
        }}
    it "should not be valid to send to self" do
      reslyp = user.user_slyps.first.send_slyp(user.email, "not valid reslyp")
      expect(reslyp.valid?).to be false
    end

    it "should not be valid to reslyp without sender" do
      reslyp_params.delete(:sender_id)
      reslyp = Reslyp.create(reslyp_params)
      expect(reslyp.valid?).to be false
    end

    it "should not be valid to reslyp without recipient" do
      reslyp_params.delete(:recipient_id)
      reslyp = Reslyp.create(reslyp_params)
      expect(reslyp.valid?).to be false
    end

    it "should not be valid to reslyp without sender_user_slyp" do
      reslyp_params.delete(:sender_user_slyp_id)
      reslyp = Reslyp.create(reslyp_params)
      expect(reslyp.valid?).to be false
    end

    it "should not be valid to reslyp without recipient_user_slyp" do
      reslyp_params.delete(:recipient_user_slyp_id)
      reslyp = Reslyp.create(reslyp_params)
      expect(reslyp.valid?).to be false
    end

    it "should not be valid to not include comment" do
      reslyp_params.delete(:comment)
      reslyp = Reslyp.create(reslyp_params)
      expect(reslyp.valid?).to be false
    end

    it "sender should own sender_user_slyp" do
      reslyp_params[:sender_id] = FactoryGirl.create(:user).id
      reslyp = Reslyp.create(reslyp_params)
      expect(reslyp.valid?).to be false
    end

    it "recipient should own recipient_user_slyp" do
      reslyp_params[:recipient_id] = FactoryGirl.create(:user).id
      reslyp = Reslyp.create(reslyp_params)
      expect(reslyp.valid?).to be false
    end
  end
end
