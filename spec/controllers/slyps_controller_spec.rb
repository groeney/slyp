require "rails_helper"
RSpec.describe SlypsController, type: :controller do
  describe "#create" do
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
