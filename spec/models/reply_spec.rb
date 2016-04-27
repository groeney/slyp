require "rails_helper"

RSpec.describe Reply, type: :model do
  context "associations" do
    it { is_expected.to belong_to :reslyp }
    it { is_expected.to belong_to :sender }
  end

  context "validations on valid model" do
    let(:user) { FactoryGirl.create(:user, :with_reslyps_and_replies) }
    it "should ensure all replies are valid" do
      user.user_slyps.each do |user_slyp|
        user_slyp.reslyps.each do |reslyp|
          reslyp.replies.each do |reply|
            expect(reply.valid?).to be true
          end
        end
      end
    end

    it "should validate sender is on parent reslyp" do
      reply = user.user_slyps.first.reslyps.first.replies.first
      expect(reply.valid?).to be true
      reply.update({ :sender_id => FactoryGirl.create(:user).id })
      expect(reply.valid?).to be false
    end
  end
end
