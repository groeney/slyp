require "rails_helper"

RSpec.describe SearchController, type: :controller do
  describe "#users" do
    let(:expected_keys) { ["display_name", "email"] }
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
        expect(response_body_json.length).to eq User.all.length
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
    let(:expected_keys) { ["id", "display_url", "title", "site_name", "latest_comment",
    "author", "slyp_id", "url", "archived", "favourite", "deleted", "duration",
    "unseen", "unseen_activity", "friends_count", "total_reslyps", "slyp_type", "html"] }
    context "user has no slyps" do
      it "should return nothing" do
        sign_in FactoryGirl.create(:user)
        get :user_slyps, q: "",  format: :json

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
        get :user_slyps, q: "", format: :json

        response_body_json = JSON.parse(response.body)
        expect(response.status).to eq 200
        expect(response_body_json.length).to eq user.user_slyps.length
      end
      it "should return data in correct format" do
        get :user_slyps, q: "", format: :json

        response_body_json = JSON.parse(response.body)
        expect(response.status).to eq 200
        response_body_json.each do |user_slyp|
          expect(user_slyp.keys).to contain_exactly(*expected_keys)
        end
      end
    end
  end
end
