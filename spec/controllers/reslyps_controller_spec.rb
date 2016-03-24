require "rails_helper"

RSpec.describe ReslypsController, type: :controller do
  describe "#create" do
    context "with invalid params" do
      let(:user) { FactoryGirl.create(:user, :with_user_slyps) }
      before do
        sign_in user
      end
      it "responds with 422" do
        post :create, slyp_id: user.user_slyps.first.slyp_id,
        emails: [user.email], comment: "This is a comment", format: :json

        expect(response.status).to eq(422)
        expect(response.content_type).to eq(Mime::JSON)
      end
    end

    context "with missing params" do
      let(:user) { FactoryGirl.create(:user, :with_user_slyps) }
      before do
        sign_in user
      end
      it "responds with 404" do
        post :create, format: :json

        expect(response.status).to eq(404)
        expect(response.content_type).to eq(Mime::JSON)
      end

      it "responds with 404, no emails" do
        post :create, slyp_id: user.user_slyps.first.slyp_id,
          comment: "This is a comment", format: :json

        expect(response.status).to eq(404)
        expect(response.content_type).to eq(Mime::JSON)
      end

      it "responds with 404, no slyp_id" do
        post :create, comment: "This is a comment",
          emails: [user.email], format: :json

        expect(response.status).to eq(404)
        expect(response.content_type).to eq(Mime::JSON)
      end

      it "responds with 404, no comment" do
        post :create, emails: [user.email],
          slyp_id: user.user_slyps.first.slyp_id, format: :json

        expect(response.status).to eq(404)
        expect(response.content_type).to eq(Mime::JSON)
      end
    end

    context "with valid params" do
      let(:user) { FactoryGirl.create(:user, :with_user_slyps) }
      let(:to_users) { FactoryGirl.create_list(:user, 10) }
      before do
        sign_in user
      end
      it "responds with 201 and valid body" do
        post :create, slyp_id: user.user_slyps.first.slyp_id,
          emails: to_users.map { |to_user| to_user.email},
          comment: "This is a comment", format: :json

        expect(response.status).to eq(201)
        expect(response.content_type).to eq(Mime::JSON)

        response_body_json = JSON.parse(response.body)
        response_body_json.each do |reslyp_json|
          reslyp = Reslyp.find(reslyp_json["id"])
          expect(reslyp).not_to be_nil
          expect(reslyp.sibling).not_to be_nil
        end
      end
    end
  end

  describe "#index" do
    context "with invalid params" do
      let(:user) { FactoryGirl.create(:user) }
      let(:user_slyp) { FactoryGirl.create(:user_slyp) }
      before do
        sign_in user
      end
      it "responds with 404" do
        get :index, format: :json

        expect(response.status).to eq(404)
        expect(response.content_type).to eq(Mime::JSON)
      end
      it "responds with 404" do
        get :index, slyp_id: user_slyp.slyp_id, format: :json

        expect(response.status).to eq(404)
        expect(response.content_type).to eq(Mime::JSON)
      end
    end

    context "with valid params" do
      let(:user) { FactoryGirl.create(:user, :with_reslyps) }
      let(:user_slyp) { user.user_slyps.first }
      before do
        sign_in user
      end

      it "responds with 200" do
        get :index, user_slyp_id: user_slyp.id, format: :json

        response_body_json = JSON.parse(response.body)
        expect(response.status).to eq(200)
        expect(response.content_type).to eq(Mime::JSON)
        expect(response_body_json.length).to eq(user_slyp.reslyps.length)

        first_reslyp = response_body_json.first
        expect(first_reslyp["id"]).not_to be_nil
        expect(first_reslyp["sender"]).to eq(!!first_reslyp["sender"])
        expect(first_reslyp["user"]).not_to be_nil
        expect(first_reslyp["user"]["id"]).not_to be_nil
      end
    end
  end

  describe "#destroy" do
    context "with invalid reslyp setup" do
      let(:user) { FactoryGirl.create(:user, :with_user_slyps) }
      let(:user_slyp) { user.user_slyps.first }
      let(:reslyp) { user_slyp.reslyps.create({
                      :user_id => user.id,
                      :sender => true,
                      :slyp_id => user_slyp.slyp_id
                      }) }
      before do
        sign_in user
      end
      it "responds with 404" do
        delete :destroy, id: reslyp.id, format: :json

        expect(response.status).to eq(404)
        expect(response.content_type).to eq(Mime::JSON)
      end
    end

    context "with valid params" do
      let(:user) { FactoryGirl.create(:user, :with_reslyps) }
      before do
        sign_in user
      end
      it "responds with 204" do
        delete :destroy, id: user.reslyps.first.id, format: :json

        expect(response.status).to eq(204)
      end
    end
  end
end
