require "rails_helper"

RSpec.describe Friendship, type: :model do
  context "associations" do
    it { is_expected.to belong_to :user }
    it { is_expected.to belong_to :friend }
  end

   context "validations" do
      it "should enforce uniqueness of user scoped to friend" do
        friendship_1 = FactoryGirl.create(:friendship)
        expect(friendship_1.valid?).to be true
        friendship_2 = Friendship.create({
          :user_id => friendship_1.user_id,
          :friend_id => friendship_1.friend_id
          })
        expect(friendship_2.valid?).to be false
      end
    end
end
