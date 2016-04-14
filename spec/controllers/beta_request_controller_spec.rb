require "rails_helper"

RSpec.describe BetaRequestController, type: :controller do
  describe "#create" do
    context "email has already been submitted" do
      let(:beta_request) { FactoryGirl.create(:beta_request) }
      it "respond with a 422" do
        request.accept = "application/json"
        post :create, email: beta_request.email, format: :json

        expect(response.status).to eq(422)
      end
    end
    context "correct params not supplied" do
      it "respond with a 400" do
        post :create, format: :json

        expect(response.status).to eq(400)
      end
    end
    context "valid request" do
      it "respond with a 201 and priority" do
        post :create, email: "new_email@example.com", format: :json

        response_body_json = JSON.parse(response.body)
        expect(response.content_type).to eq(Mime::JSON)
        expect(response.status).to eq(201)
        expect(response_body_json["priority"]).to be_kind_of Integer
      end
    end
  end

end
