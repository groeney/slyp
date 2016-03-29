# NOTE: This is a non-critical controller, used for background slyp creations, no
# response data epected
require "rails_helper"
RSpec.describe SlypsController, type: :controller do
  describe "#create" do
    context "url is valid but slyp already exists", :vcr do
      it "responds with 200" do
        url = "https://www.farnamstreetblog.com/2014/02/quotable-kierkegaard/"
        Slyp.fetch(url)
        post :create, url: url, format: :json

        expect(response.status).to eq(200)
      end
    end

    context "url is valid and slyp doesn't exist", :vcr do
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
