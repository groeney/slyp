require "rails_helper"

RSpec.describe UsersController, type: :controller do
  describe "#friends" do
    context "user has friends" do
      let(:user) { FactoryGirl.create(:user, :with_reslyps) }
      before do
        sign_in user
      end
      it "responds with 200 and list of all users' friends" do
        get :friends, format: :json

        response_body_json = JSON.parse(response.body)
        expect(response.status).to eq 200
        expect(response.content_type).to eq Mime::JSON
        expect(response_body_json.length).to eq user.friends.length
      end
    end
  end
end
