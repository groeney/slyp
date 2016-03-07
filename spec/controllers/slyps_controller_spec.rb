require "rails_helper"

RSpec.describe SlypsController, type: :controller do
  describe "#create" do
    context "without authentication", :vcr do
      it "responds with 401" do
        url = "https://www.farnamstreetblog.com/2014/02/quotable-kierkegaard/"
        post :create, url: url, format: :json

        expect(response.status).to eq(401)
      end
    end

    context "with authentication and invalid parameters", :vcr do
      it "responds wth 422" do
        sign_in FactoryGirl.create(:user)
        url = "http://www.foobarbaziamafaker.co/"
        post :create, url: url, format: :json

        expect(response.status).to eq(422)
        expect(response.content_type).to eq(Mime::JSON)
      end
    end
    context "with authentication and valid parameters", :vcr do
      it "responds with 201 and minimal slyp attrs" do
        sign_in FactoryGirl.create(:user)
        url = "https://www.farnamstreetblog.com/2014/02/quotable-kierkegaard/"
        post :create, url: url, format: :json

        json_response_body = JSON.parse(response.body)
        expect(response.status).to eq(201)
        expect(response.content_type).to eq(Mime::JSON)
        expect(json_response_body["archived"]).not_to be_nil
        expect(json_response_body["deleted"]).not_to be_nil
        expect(json_response_body["favourite"]).not_to be_nil
      end
    end
  end
end
