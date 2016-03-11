require "rails_helper"

RSpec.describe Reslyp, type: :model do
  context "associations" do
    it { is_expected.to belong_to :slyp }
    it { is_expected.to belong_to :user_slyp }
    it { is_expected.to belong_to :user }
  end

 context "validations" do
    it "should enforce uniqueness of user_slyp scoped to user" do
      user = FactoryGirl.create(:user, :with_user_slyps)
      user_slyp = user.user_slyps.first
      reslyp = user_slyp.reslyps.create({
                      :user_id => user.id,
                      :sender => true,
                      :slyp_id => user_slyp.slyp_id
                      })
      expect(reslyp.valid?).to be true
      reslyp_2 = user_slyp.reslyps.create({
                      :user_id => user.id,
                      :sender => true,
                      :slyp_id => user_slyp.slyp_id
                      })
      expect(reslyp_2.valid?).to be false
    end

    it "should enforce that reslyp has a valid sibling" do
      user = FactoryGirl.create(:user, :with_reslyps)
      reslyp = user.reslyps.first
      expect(reslyp.sibling).not_to be_nil
    end
  end
end
