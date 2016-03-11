require "rails_helper"

RSpec.describe UserSlypsController, type: :controller do
  describe "#create" do
    context "with invalid parameters", :vcr do
      it "responds wth 422" do
        sign_in FactoryGirl.create(:user)
        url = "http://www.foobarbaziamafaker.co/"
        post :create, url: url, format: :json

        expect(response.status).to eq(422)
        expect(response.content_type).to eq(Mime::JSON)
      end
    end

    context "with valid parameters", :vcr do
      it "responds with 201 and minimal slyp attrs" do
        sign_in FactoryGirl.create(:user)
        url = "https://www.farnamstreetblog.com/2014/02/quotable-kierkegaard/"
        post :create, url: url, format: :json

        response_body_json = JSON.parse(response.body)
        expect(response.status).to eq(201)
        expect(response.content_type).to eq(Mime::JSON)

        expect(response_body_json["archived"]).not_to be_nil
        expect(response_body_json["deleted"]).not_to be_nil
        expect(response_body_json["favourite"]).not_to be_nil
        expect(response_body_json["reslyps"]).to be >= 1
        expect(response_body_json["friend_reslyps"]).not_to be_nil
      end
    end
  end

  describe "#index" do
    context "with authentication and reslyps" do
      let(:user) { FactoryGirl.create(:user, :with_reslyps) }
      before do
        sign_in user
      end
      it "responds with 200 and correct number of slyps" do
        get :index, format: :json

        response_body_json = JSON.parse(response.body)
        expect(response.status).to eq(200)
        expect(response_body_json.length).to eq(10)
      end
    end
  end
end
