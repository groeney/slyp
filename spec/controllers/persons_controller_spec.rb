require "rails_helper"

RSpec.describe PersonsController, type: :controller do
  describe "#index" do
    context "user has friends" do
      let(:user) { FactoryGirl.create(:user, :with_reslyps) }
      before do
        sign_in user
      end
      it "should return correct number of users" do
        get :index, format: :json
        response_body_json = JSON.parse(response.body)
        expect(response_body_json.length).to eq User.all.count
      end
      it "should only return emails for friends" do
        expect(user.friends.count).to be > 0
        get :index, format: :json
        response_body_json = JSON.parse(response.body)
        friend_ids = user.friends.pluck(:id)
        response_body_json.each do |person_json|
          if person_json["email"].blank?
            expect(friend_ids.include? person_json["id"]).to be false
          else
            expect(friend_ids.include? person_json["id"]).to be true
          end
        end
      end
    end
    context "user has no friends" do
      let(:user) { FactoryGirl.create(:user) }
      before do
        sign_in user
      end
      it "should not return any emails" do
        get :index, format: :json
        response_body_json = JSON.parse(response.body)
        response_body_json.each do |person_json|
          expect(person_json["email"].blank?).to be true
        end
      end
    end
    context "user not signed in" do
      let(:user) { FactoryGirl.create(:user) }
      it "should resond with 401" do
        get :index, format: :json
        expect(response.status).to eq 401
      end
    end
  end
  describe "#show" do
    context "user signed in" do
      let(:user) { FactoryGirl.create(:user, :with_reslyps) }
      before do
        sign_in user
      end
      it "should return email" do
        friend = FactoryGirl.create(:user)
        user.befriend(friend.id)
        get :show, id: friend.id, format: :json
        response_body_json = JSON.parse(response.body)
        expect(response_body_json["email"]).to eq friend.email
      end
      it "should not return email" do
        friend = FactoryGirl.create(:user)
        get :show, id: friend.id, format: :json
        response_body_json = JSON.parse(response.body)
        expect(response_body_json["email"].blank?).to be true
      end
      it "should respond with 200" do
        get :show, id: user.friends.first.id, format: :json
        expect(response.status).to eq 200
      end
      it "should respond with 404" do
        get :show, id: 0, format: :json
        expect(response.status).to eq 404
      end
    end
    context "user not signed in" do
      let(:user) { FactoryGirl.create(:user, :with_reslyps) }
      it "should respond with 401" do
        get :show, id: user.friends.first.id, format: :json
        expect(response.status).to eq 401
      end
    end
  end
end
