require "rails_helper"

RSpec.describe ReslypsController, type: :controller do
  let(:expected_keys) { ["id", "sender", "recipient", "comment", "created_at", "reply_count",
                         "unseen_replies"] }
  describe "#create" do
    context "with invalid params" do
      let(:user) { FactoryGirl.create(:user, :with_user_slyps) }
      before do
        sign_in user
      end
      it "should respond to reslyp to self with 422" do
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
      it "should respond to no params with 400" do
        post :create, format: :json

        expect(response.status).to eq(400)
        expect(response.content_type).to eq(Mime::JSON)
      end

      it "should respond to no emails with 400" do
        post :create, slyp_id: user.user_slyps.first.slyp_id,
          comment: "This is a comment", format: :json

        expect(response.status).to eq(400)
        expect(response.content_type).to eq(Mime::JSON)
      end

      it "should respond to no slyp_id with 400" do
        post :create, comment: "This is a comment",
          emails: [user.email], format: :json

        expect(response.status).to eq(400)
        expect(response.content_type).to eq(Mime::JSON)
      end

      it "should respond to no comment with 400" do
        post :create, emails: [user.email],
          slyp_id: user.user_slyps.first.slyp_id, format: :json

        expect(response.status).to eq(400)
        expect(response.content_type).to eq(Mime::JSON)
      end
    end

    context "with valid params" do
      let(:user) { FactoryGirl.create(:user, :with_user_slyps) }
      let(:to_users) { FactoryGirl.create_list(:user, 10) }
      let(:to_user) { to_users.first }
      let(:user_slyp) { user.user_slyps.first }
      before do
        sign_in user
      end
      it "responds with 201" do
        post :create, slyp_id: user_slyp.slyp_id,
          emails: to_users.map { |to_user| to_user.email},
          comment: "This is a comment", format: :json

        expect(response.status).to eq(201)
        expect(response.content_type).to eq(Mime::JSON)
      end

      it "responds with valid body" do
        post :create, slyp_id: user_slyp.slyp_id,
          emails: to_users.map { |to_user| to_user.email},
          comment: "This is a comment", format: :json

        response_body_json = JSON.parse(response.body)
        response_body_json.each do |reslyp_json|
          reslyp = Reslyp.find(reslyp_json["id"])
          expect(reslyp.valid?).to be true
          expect(reslyp_json.keys).to contain_exactly(*expected_keys)
        end
      end

      it "should set unseen and unseen_activity on user_slyp" do
        post :create, slyp_id: user_slyp.slyp_id,
          emails: to_users.map { |to_user| to_user.email},
          comment: "This is a comment", format: :json
        response_body_json = JSON.parse(response.body)
        response_body_json.each do |reslyp_json|
          reslyp = Reslyp.find(reslyp_json["id"])
          expect(reslyp.recipient_user_slyp.unseen_activity).to be true
          expect(reslyp.recipient_user_slyp.unseen).to be true
        end
      end
      it "should not set unseen on user_slyp" do
        to_user.user_slyps.create(slyp_id: user_slyp.slyp_id)
        post :create, slyp_id: user_slyp.slyp_id, emails: [to_user.email],
                      comment: "This is a comment", format: :json
        response_body_json = JSON.parse(response.body)
        response_body_json.each do |reslyp_json|
          reslyp = Reslyp.find(reslyp_json["id"])
          expect(reslyp.recipient_user_slyp.unseen_activity).to be true
          expect(reslyp.recipient_user_slyp.unseen).to be false
        end
      end
    end
  end

  describe "#index" do
    context "with invalid params" do
      let(:user) { FactoryGirl.create(:user, :with_reslyps) }
      let(:user_slyp) { FactoryGirl.create(:user_slyp, :with_reslyp) }
      before do
        sign_in user
      end

      it "should respond to incorrect owner with 404" do
        get :index, id: user_slyp.id, format: :json

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
        get :index, id: user_slyp.id, format: :json

        response_body_json = JSON.parse(response.body)
        expect(response.status).to eq(200)
        expect(response.content_type).to eq(Mime::JSON)
      end

      it "responds with correct data" do
        get :index, id: user_slyp.id, format: :json

        response_body_json = JSON.parse(response.body)
        expect(response_body_json.length).to eq(user_slyp.reslyps.length)
        response_body_json.each do |reslyp|
          expect(user_slyp.reslyps.find(reslyp["id"]).valid?).to be true
          expect(reslyp.keys).to contain_exactly(*expected_keys)
        end
      end
    end
  end
end
