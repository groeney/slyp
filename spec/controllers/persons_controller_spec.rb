require "rails_helper"

RSpec.describe PersonsController, type: :controller do
  let(:expected_keys) { ["id", "first_name", "last_name", "email", "display_name", "image",
             "friendship_id", "status"] }
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
      it "should respond with 200" do
        get :index, format: :json
        expect(response.status).to eq 200
        expect(response.content_type).to eq(Mime::JSON)
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
      it "should respond with 200" do
        get :show, id: user.friends.last.id, format: :json
        expect(response.status).to eq 200
        expect(response.content_type).to eq(Mime::JSON)
      end
      it "should respond with 404" do
        get :show, id: 0, format: :json
        expect(response.status).to eq 404
      end
      it "should respond with expected_keys" do
        get :show, id: user.friends.last.id, format: :json
        response_body_json = JSON.parse(response.body)
        expect(response_body_json.keys).to contain_exactly(*expected_keys)
      end
    end
    context "user not signed in" do
      let(:user) { FactoryGirl.create(:user, :with_reslyps) }
      it "should respond with 401" do
        get :show, id: user.friends.last.id, format: :json
        expect(response.status).to eq 401
      end
    end
  end
  describe "#invite" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      sign_in user
    end
    it "should send invitation email" do
      perform_enqueued_jobs do
        invite_email = "#{SecureRandom.hex(8)}@example.com"
        post :invite, email: invite_email, format: :json
        delivered_email = ActionMailer::Base.deliveries.last
        expect(delivered_email.to.first).to eq invite_email
        expect(delivered_email.subject).to include("invited you")
      end
    end
    it "should resond with 201" do
      invite_email = "#{SecureRandom.hex(8)}@example.com"
      post :invite, email: invite_email, format: :json
      expect(response.status).to eq 201
      expect(response.content_type).to eq(Mime::JSON)
    end
    it "should respond with 422" do
      post :invite, email: "invalidemail", format: :json
      expect(response.status).to eq 422
    end
    it "should respond with expected_keys" do
      post :invite, email: "#{SecureRandom.hex(8)}@example.com", format: :json
      response_body_json = JSON.parse(response.body)
      expect(response_body_json.keys).to contain_exactly(*expected_keys)
    end
  end
end
