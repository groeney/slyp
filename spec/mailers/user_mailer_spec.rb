require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  describe "beta_request_email" do
    let(:beta_request) { FactoryGirl.create(:beta_request) }
    let(:mail) { UserMailer.beta_request_email(beta_request) }

    it "renders the subject" do
      expect(mail.subject).to eql("Waiting for Slyp Beta")
    end

    it "renders the receiver email" do
      expect(mail.to).to eql([beta_request.email])
    end

    it "renders the sender email" do
      expect(mail.from).to eql(["robot@slyp.io"])
    end
  end

  describe "beta_invitation_email" do
    let(:beta_request) { FactoryGirl.create(:beta_request) }
    let(:mail) { UserMailer.beta_invitation_email(beta_request) }

    it "renders the subject" do
      expect(mail.subject).to eql("Your invitation to Slyp Beta :)")
    end

    it "renders the receiver email" do
      expect(mail.to).to eql([beta_request.email])
    end

    it "renders the sender email" do
      expect(mail.from).to eql(["robot@slyp.io"])
    end
  end

end
