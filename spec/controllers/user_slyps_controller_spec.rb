require "rails_helper"

RSpec.describe UserSlypsController, type: :controller do
  let(:expected_keys) { ["id", "display_url", "title", "site_name", "latest_comment",
  "author", "slyp_id", "url", "archived", "favourite", "deleted", "duration",
  "unseen", "unseen_activity", "friends", "total_reslyps", "slyp_type", "html"] }
  describe "#create" do
    let(:user) { FactoryGirl.create(:user) }
    context "without authentication" do
      it "responds with 401" do
        url = "https://www.farnamstreetblog.com/2014/02/quotable-kierkegaard/"
        post :create, url: url, format: :json

        expect(response.status).to eq(401)
        expect(response.content_type).to eq(Mime::JSON)
      end
    end

    context "valid url by standards but not a real webpage", :vcr do
      it "responds wth 201" do
        sign_in user
        url = "http://www.foobarbaziamafaker.co/"
        post :create, url: url, format: :json

        expect(response.status).to eq 201
        expect(response.content_type).to eq(Mime::JSON)
      end
    end

    context "invalid url by standards", :vcr do
      it "responds wth 422" do
        sign_in user
        url = "http||iamnotavalidurl"
        post :create, url: url, format: :json

        expect(response.status).to eq 422
        expect(response.content_type).to eq(Mime::JSON)
      end
    end

    context "with valid parameters", :vcr do
      let(:url) { "https://www.farnamstreetblog.com/2014/02/quotable-kierkegaard/" }
      before do
        sign_in user
      end

      it "responds with 201 and correct response hash keys" do
        post :create, url: url, format: :json

        response_body_json = JSON.parse(response.body)
        expect(response.status).to eq(201)
        expect(response.content_type).to eq(Mime::JSON)
        expect(response_body_json.keys).to contain_exactly(*expected_keys)
      end

      it "responds with unseen and unseen_activity both false" do
        post :create, url: url, format: :json

        response_body_json = JSON.parse(response.body)
        expect(response_body_json["unseen"]).to be false
        expect(response_body_json["unseen_activity"]).to be false
      end
    end
  end

  describe "#index" do
    context "user with reslyps" do
      it "responds with 200 and correct number of slyps" do
        sign_in FactoryGirl.create(:user, :with_reslyps)
        get :index, format: :json

        response_body_json = JSON.parse(response.body)
        expect(response.status).to eq(200)
        response_body_json.each do |user_slyp|
          expect(user_slyp.keys).to contain_exactly(*expected_keys)
        end
      end
    end
  end

  describe "#show" do
    context "friend sends user a slyp" do
      let(:user) { FactoryGirl.create(:user, :with_reslyps) }
      let(:friend) { FactoryGirl.create(:user, :with_reslyps) }
      let(:friend_user_slyp) { friend.user_slyps.first }
      before do
        sign_in user
        friend_user_slyp.send_slyp(user.email, "This is a comment")
      end
      it "should not return friend's user_slyp" do
        put :show, id: friend_user_slyp.id, format: :json

        expect(response.status).to eq(404)
        expect(response.content_type).to eq(Mime::JSON)
      end
      it "responds with 200 and correct data" do
        user_slyp = user.user_slyps.find_by({:slyp_id => friend_user_slyp.slyp_id})
        put :show, id: user_slyp.id, format: :json

        response_body_json = JSON.parse(response.body)
        expect(response.status).to eq(200)
        expect(response_body_json["friends"].length).to eq 1
        expect(response.content_type).to eq(Mime::JSON)
      end
    end

    context "single user with multiple friends" do
      let(:user) { FactoryGirl.create(:user, :with_user_slyps) }
      let(:user_slyp) { user.user_slyps.first }
      let(:friends) { FactoryGirl.create_list(:user, 10) }
      let(:friend_emails) { friends.map(&:email) }

      it "should respond with 200 and correct data" do
        sign_in user
        user_slyp.send_slyps(friend_emails, "This is a comment")
        put :show, id: user_slyp.id, format: :json

        response_body_json = JSON.parse(response.body)
        expect(response.status).to eq 200
        expect(response.content_type).to eq Mime::JSON
        expect(response_body_json["friends"].length).to eq 10
      end
    end
  end

  describe "#update" do
    let(:user) { FactoryGirl.create(:user, :with_user_slyps) }
    let(:user_slyp) { user.user_slyps.first }
    before do
      sign_in user
    end
    context "with invalid parameters" do
      let(:charlatan) { FactoryGirl.create(:user_slyp) }
      it "responds with 422" do
        put :update, id: user_slyp.id, user_slyp: { favourite: nil }, format: :json

        expect(response.status).to eq(422)
        expect(response.content_type).to eq(Mime::JSON)
      end

      it "responds with 404" do
        put :update, id: charlatan.id, user_slyp: { favourite: false }, format: :json

        expect(response.status).to eq(404)
        expect(response.content_type).to eq(Mime::JSON)
      end
    end

    context "with valid parameters" do
      it "toggles favourite and responds with 200" do
        put :update, id: user_slyp.id, user_slyp: { favourite: !user_slyp.favourite }, format: :json

        response_body_json = JSON.parse(response.body)
        expect(response.status).to eq(200)
        expect(response.content_type).to eq(Mime::JSON)
        expect(response_body_json["favourite"]).to eq !user_slyp.favourite
      end

      it "toggles archived and responds with 200" do
        put :update, id: user_slyp.id, user_slyp: { archived: !user_slyp.archived }, format: :json

        response_body_json = JSON.parse(response.body)
        expect(response.status).to eq(200)
        expect(response.content_type).to eq(Mime::JSON)
        expect(response_body_json["archived"]).to eq !user_slyp.archived
      end

      it "toggles deleted and responds with 200" do
        put :update, id: user_slyp.id, user_slyp: { deleted: !user_slyp.deleted }, format: :json

        response_body_json = JSON.parse(response.body)
        expect(response.status).to eq(200)
        expect(response.content_type).to eq(Mime::JSON)
        expect(response_body_json["deleted"]).to eq !user_slyp.deleted
      end
    end
  end
end