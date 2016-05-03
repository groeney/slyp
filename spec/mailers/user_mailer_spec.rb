require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  describe "beta_invitation" do
    let(:beta_request) { FactoryGirl.create(:beta_request) }
    let(:mail) { UserMailer.beta_invitation(beta_request) }

    it "renders the subject" do
      expect(mail.subject).to eql("your invitation to slyp beta :)")
    end

    it "renders the receiver email" do
      expect(mail.to).to eql([beta_request.email])
    end

    it "renders the sender email" do
      expect(mail.from).to eql(["jamesgroeneveld@gmail.com"])
    end
  end

end
