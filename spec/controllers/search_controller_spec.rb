require 'rails_helper'

RSpec.describe SearchController, type: :controller do
  describe "#users" do
    context "Platform has no users" do
      it "should return nothing" do
        post :users, format: :json

        response_body_json = JSON.parse(response.body)
        expect(response.status).to eq 200
        expect(response_body_json.length).to eq 0
      end
    end
    context "Platform has 10 James' and others" do
      before do
        FactoryGirl.create_list(:user, 10, first_name: "James")
        FactoryGirl.create_list(:user, 100)
      end
      it "should return all James users" do
        post :users, q: 'James', format: :json

        response_body_json = JSON.parse(response.body)
        expect(response.status).to eq 200
        expect(response_body_json.length).to eq 10
      end
      it "should return all users" do
        post :users, q: '', format: :json

        response_body_json = JSON.parse(response.body)
        expect(response.status).to eq 200
        expect(response_body_json.length).to eq User.all.length
      end
      it "should return data in correct format" do
        post :users, q: '', format: :json

        response_body_json = JSON.parse(response.body)
        expect(response.status).to eq 200
        response_body_json.each do |user|
          expect(user["name"]).not_to be_nil
          expect(user["value"]).not_to be_nil
          expect(user["description"]).not_to be_nil
        end
      end
    end
  end
end
