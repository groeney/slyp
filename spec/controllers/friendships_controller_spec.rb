require "rails_helper"

RSpec.describe FriendshipsController, type: :controller do
  let(:expected_keys) { ["id", "friend_id", "email", "display_name"] }
  let(:user) { FactoryGirl.create(:user, :with_friends) }
  let(:prospect) { FactoryGirl.create(:user) }

  describe "#create" do
    context "user already has friends" do
      before do
        sign_in user
      end

      it "should be successful even when friendship exists" do
        post :create, user_id: user.friends.last.id, format: :json
        expect(response.status).to eq(201)
        expect(response.content_type).to eq(Mime::JSON)
      end

      it "should set friendship to active from pending" do
        friend_id = user.friends.last.id
        user.friendship(friend_id).pending!
        post :create, user_id: friend_id, format: :json
        expect(user.friendship(friend_id).active?).to be true
      end

      it "should successfully create new resource" do
        post :create, user_id: prospect.id, format: :json
        expect(response.status).to eq(201)
        expect(response.content_type).to eq(Mime::JSON)
      end

      it "should return resource with correct data" do
        post :create, user_id: prospect.id, format: :json
        response_body_json = JSON.parse(response.body)
        expect(response_body_json.keys).to contain_exactly(*expected_keys)
      end

      it "should send friendship notification" do
        perform_enqueued_jobs do
          post :create, user_id: prospect.id, format: :json
          delivered_email = ActionMailer::Base.deliveries.last
          expect(delivered_email.to.first).to eq prospect.email
          expect(delivered_email.subject).to include("joined you on Slyp")
        end
      end

      it "should not send friendship notification" do
        perform_enqueued_jobs do
          friend_id = user.friends.last.id
          user.friendship(friend_id).pending!
          post :create, user_id: user.friends.last.id, format: :json
          expect(ActionMailer::Base.deliveries).to be_empty
        end
      end
    end
  end

  describe "#destroy" do
    let(:user) { FactoryGirl.create(:user, :with_reslyps) }
    before do
      sign_in user
    end

    it "should keep friendship set to active?" do
      immutable_friendship = user.friendships.last
      expect(immutable_friendship.active?).to be true
      delete :destroy, id: immutable_friendship.id, format: :json
      expect(response.status).to eq 403
      expect(response.content_type).to eq(Mime::JSON)
      expect(user.friendships.find_by(id: immutable_friendship.id).active?).to be true
    end

    it "should set friendship to pending" do
      prospect = FactoryGirl.create(:user)
      user.befriend(prospect.id)
      new_friendship = user.friendships.where(friend_id: prospect.id).first
      expect(new_friendship.active?).to be true
      delete :destroy, id: new_friendship.id, format: :json
      expect(response.status).to eq 200
      expect(response.content_type).to eq(Mime::JSON)
      expect(user.friendships.find_by(id: new_friendship.id).pending?).to be true
    end
  end
end
