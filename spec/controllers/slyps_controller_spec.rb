require "rails_helper"
RSpec.describe SlypsController, type: :controller do
  describe "#create" do
    context "slyp already exists", :vcr do
      let(:url) { "https://www.farnamstreetblog.com/2014/02/quotable-kierkegaard/" }
      let(:slyp) { Slyp.fetch(url) }
      it "should return correct slyp" do
        post :create, url: slyp.url, format: :json

        response_body_json = JSON.parse(response.body)
        expect(response_body_json["id"]).to eq(slyp.id)
      end

      it "should not duplicate slyp" do
        query_params = "?foo=foo&bar=bar"
        post :create, url: slyp.url + query_params, format: :json

        response_body_json = JSON.parse(response.body)
        expect(response_body_json["id"]).to eq(slyp.id)
      end
    end

    context "slyp doesn't already exist", :vcr do
      it "responds wth 201" do
        url = "https://www.farnamstreetblog.com/2014/02/quotable-kierkegaard/"
        post :create, url: url, format: :json

        expect(response.status).to eq 201
      end
    end

    context "valid url by standards but not a real webpage", :vcr do
      it "responds with 201" do
        url = "http://v"
        post :create, url: url, format: :json

        expect(response.status).to eq(201)
      end
    end

    context "invalid url by standards", :vcr do
      it "responds with 422" do
        url = "http||iamnotavalidurl"
        post :create, url: url, format: :json

        expect(response.status).to eq(422)
      end
    end
  end

end
