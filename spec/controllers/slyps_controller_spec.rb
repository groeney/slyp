require "rails_helper"

RSpec.describe SlypsController, type: :controller do
  describe "#create" do
    context "with invalid parameters", :vcr do
      it "responds wth 422" do
        url = "http://www.foobarbaziamafaker.co/"
        post :create, url: url, format: :json

        expect(response.status).to eq(422)
        expect(response.content_type).to eq(Mime::JSON)
      end
    end
    context "with valid parameters", :vcr do
      it "responds with 201 and minimal slyp attrs" do
        url = "https://www.farnamstreetblog.com/2014/02/quotable-kierkegaard/"
        post :create, url: url, format: :json

        expect(response.status).to eq(201)
        expect(response.content_type).to eq(Mime::JSON)
      end
    end
  end
end
