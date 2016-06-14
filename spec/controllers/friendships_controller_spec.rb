require "rails_helper"

RSpec.describe FriendshipsController, type: :controller do
  let(:expected_keys) { ["id", "friend"] }
  let(:expected_friend_keys) { ["id", "first_name", "last_name", "email", "image"] }
  let(:user) { FactoryGirl.create(:user, :with_friends) }
  let(:prospect) { FactoryGirl.create(:user) }

  describe "#create" do
    context "user already has friends" do
      before do
        sign_in user
      end

      it "should be successful even when friendship exists" do
        post :create, user_id: user.friends.first.id, format: :json
        expect(response.status).to eq(201)
        expect(response.content_type).to eq(Mime::JSON)
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
        expect(response_body_json["friend"].keys).to contain_exactly(*expected_friend_keys)
      end
    end
  end

  describe "#index" do
    before do
      sign_in user
    end

    it "should return correct keys" do
      get :index, format: :json
      response_body_json = JSON.parse(response.body)
      response_body_json.each do |friendship_json|
        expect(friendship_json.keys).to contain_exactly(*expected_keys)
        expect(friendship_json["friend"].keys).to contain_exactly(*expected_friend_keys)
      end
    end

    it "should successfully return all friendships" do
      get :index, format: :json
      response_body_json = JSON.parse(response.body)
      expect(response.status).to eq 200
      expect(response_body_json.length).to eq user.friends.length
    end

    it "should return newly created resources" do
      total_friends = user.friends.count
      user.befriend(prospect.id)
      expect(user.friends.count).to eq(total_friends + 1)
      get :index, format: :json
      response_body_json = JSON.parse(response.body)
      expect(response_body_json.length).to eq(total_friends + 1)
    end
  end

  describe "#destroy" do
    let(:user) { FactoryGirl.create(:user, :with_reslyps) }
    before do
      sign_in user
    end

    it "should not destroy friendship" do
      immutable_friendship = user.friendships.first
      delete :destroy, id: immutable_friendship.id, format: :json
      expect(response.status).to eq 422
      expect(response.content_type).to eq(Mime::JSON)
      expect(user.friendships.find_by(id: immutable_friendship.id)).not_to be_nil
    end

    it "should destroy friendship" do
      prospect = FactoryGirl.create(:user)
      user.befriend(prospect.id)
      new_friendship = user.friendships.where(friend_id: prospect.id).first
      expect(new_friendship.valid?).to be true
      delete :destroy, id: new_friendship.id, format: :json
      expect(response.status).to eq 204
      expect(response.content_type).to eq(Mime::JSON)
      expect(user.friendships.find_by(id: new_friendship.id)).to be_nil
    end
  end
end

















