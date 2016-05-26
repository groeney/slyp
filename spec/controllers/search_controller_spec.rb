require "rails_helper"

RSpec.describe SearchController, type: :controller do
  describe "#users" do
    let(:expected_keys) { ["id", "display_name", "email"] }
    let(:user) { FactoryGirl.create(:user) }
    before do
      sign_in user
    end
    context "with no users" do
      it "should return nothing" do
        post :users, q: "", format: :json

        response_body_json = JSON.parse(response.body)
        expect(response.status).to eq 200
        expect(response_body_json.length).to eq 0
      end
    end
    context "with 10 James' and others" do
      before do
        FactoryGirl.create_list(:user, 10, first_name: "James")
        FactoryGirl.create_list(:user, 100)
      end
      it "should return all James users" do
        post :users, q: "James", format: :json

        response_body_json = JSON.parse(response.body)
        expect(response.status).to eq 200
        expect(response_body_json.length).to eq 10
      end
      it "should return all users" do
        post :users, q: "", format: :json

        response_body_json = JSON.parse(response.body)
        expect(response.status).to eq 200
        expect(response_body_json.length).to eq User.all.length - 1
      end
      it "should return data in correct format" do
        post :users, q: "", format: :json

        response_body_json = JSON.parse(response.body)
        expect(response.status).to eq 200
        response_body_json.each do |user|
          expect(user.keys).to contain_exactly(*expected_keys)
        end
      end
    end
  end

  describe "#user_slyps" do
    let(:expected_keys) { ["id", "display_url", "title", "site_name", "latest_conversation",
    "author", "slyp_id", "url", "archived", "favourite", "deleted", "duration", "total_favourites",
    "unseen", "unseen_activity", "friends", "total_reslyps", "slyp_type", "html"] }
    let(:user) { FactoryGirl.create(:user) }
    before do
      sign_in user
    end
    context "user has no slyps" do
      it "should return nothing" do
        sign_in FactoryGirl.create(:user)
        post :user_slyps, q: "",  format: :json

        response_body_json = JSON.parse(response.body)
        expect(response.status).to eq 200
        expect(response_body_json.length).to eq 0
      end
    end
    context "user has some slyps and platform has more" do
      let(:user) { FactoryGirl.create(:user, :with_user_slyps) }
      let(:slyps) { FactoryGirl.create_list(:slyp, 100) }
      before do
        sign_in user
      end
      it "should return all current user's slyps but no more" do
        post :user_slyps, q: "", format: :json

        response_body_json = JSON.parse(response.body)
        expect(response.status).to eq 200
        expect(response_body_json.length).to eq user.user_slyps.length
      end
      it "should return data in correct format" do
        post :user_slyps, q: "", format: :json

        response_body_json = JSON.parse(response.body)
        expect(response.status).to eq 200
        response_body_json.each do |user_slyp|
          expect(user_slyp.keys).to contain_exactly(*expected_keys)
        end
      end
    end
  end

  describe "#mutual_user_slyps" do
    context "user has reslyps" do
      let(:user) { FactoryGirl.create(:user, :with_reslyps) }
      before do
        sign_in user
      end
      it "should return correct number of active user_slyps" do
        get :mutual_user_slyps, friend_id: user.id, format: :json

        response_body_json = JSON.parse(response.body)
        expect(response.status).to eq 200
        expect(response_body_json.length).to eq user.active_user_slyps.length
      end
      it "should return no user_slyps" do
        get :mutual_user_slyps, friend_id: User.last.id + 1, format: :json

        response_body_json = JSON.parse(response.body)
        expect(response.status).to eq 200
        expect(response_body_json.length).to eq 0
      end
      it "should return correct number of user_slyps" do
        friend = user.friends.first
        get :mutual_user_slyps, friend_id: friend.id, format: :json

        expected_results = user.find_mutual_user_slyps(friend.id)
        response_body_json = JSON.parse(response.body)
        expect(response.status).to eq 200
        expect(response_body_json.length).to eq expected_results.length
      end
    end
  end

  describe "#friends" do
    let(:expected_keys) { ["id", "display_name", "email"] }
    context "User has no friends" do
      let(:user) { FactoryGirl.create(:user) }
      before do
        sign_in user
      end
      it "should return no friends" do
        get :friends, q: "@bob", format: :json
        response_body_json = JSON.parse(response.body)
        expect(response.status).to eq 200
        expect(response_body_json.length).to eq 0
      end
    end
    context "User has friends" do
      let(:user) { FactoryGirl.create(:user, :with_friends) }
      before do
        sign_in user
      end
      it "should return all friends" do
        get :friends, q: "@", format: :json
        response_body_json = JSON.parse(response.body)
        expect(response.status).to eq 200
        expect(response_body_json.length).to eq user.friends.length
      end
      it "should return correct data" do
        get :friends, q: "@", format: :json
        response_body_json = JSON.parse(response.body)
        response_body_json.each do |friend|
          expect(friend.keys).to contain_exactly(*expected_keys)
        end
      end
      it "should return correct friends" do
        friends_named_joe = user.friends.where(first_name: "Joe")
        get :friends, q: "@Joe", format: :json
        response_body_json = JSON.parse(response.body)
        expect(response_body_json.length).to eq friends_named_joe.length
        response_body_json.each do |friend|
          expect(friend["display_name"].start_with?("Joe")).to be true
        end
      end
      it "should return correct friends with lowercas user_query" do
        friends_named_joe = user.friends.where(first_name: "Joe")
        get :friends, q: "@joe", format: :json
        response_body_json = JSON.parse(response.body)
        expect(response_body_json.length).to eq friends_named_joe.length
        response_body_json.each do |friend|
          expect(friend["display_name"].start_with?("Joe")).to be true
        end
      end
    end
  end
end
