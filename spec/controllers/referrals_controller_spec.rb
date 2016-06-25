require "rails_helper"

RSpec.describe ReferralsController, type: :controller do
  describe "#new" do
    render_views
    context "user signed in" do
      let(:user) { FactoryGirl.create(:user) }
      before do
        sign_in user
      end
      it "should redirect user to feed" do
        get :new, referral_token: user.referral_token, format: :html
        expect(response).to redirect_to("/feed")
      end
    end
    context "user not signed in" do
      let(:referrer) { FactoryGirl.create(:user) }
      it "should redirect to root_path" do
        get :new, referral_token: "invalid_token", format: :html
        expect(response).to redirect_to(root_path)
      end
      it "should respond with 200" do
        get :new, referral_token: referrer.referral_token, format: :html
        expect(response.status).to eq 200
      end
      it "should respond with referred_by_id in form" do # TODO : make view spec
        get :new, referral_token: referrer.referral_token, format: :html
        expect(response.body).to include "<input type=\"hidden\" name=\"referred_by_id\" id=\"referred_by_id\" value=\"#{referrer.id}\" />"
      end
      it "should respond with referrer display_name in body" do # TODO : make view spec
        get :new, referral_token: referrer.referral_token, format: :html
        expect(response.body).to include referrer.display_name
      end
    end
  end

  describe "#capture" do
    let(:referrer) { FactoryGirl.create(:user) }
    context "invalid params" do
      it "is missing referred_by_id, so should redirect to root_path" do
        post :capture, email: "#{SecureRandom.hex(8)}@example.com", format: :json
        expect(response).to redirect_to root_path
      end
      it "is invalid referred_by_id, so should redirect to root_path" do
        post :capture, referred_by_id: 0, format: :json
        expect(response).to redirect_to root_path
      end
      it "is invalid email, so should redirect to root_path" do
        post :capture, referred_by_id: referrer.id, email: SecureRandom.hex(8), format: :json
        expect(response).to redirect_to root_path
      end
      it "should redirect existing user to root_path" do
        existing_user = FactoryGirl.create(:user)
        post :capture, referred_by_id: referrer.id, email: existing_user.email, format: :json
        expect(response.status).to eq 404
      end
    end

    context "existing active user" do
      let(:user) { FactoryGirl.create(:user) }
      it "should respond with 404" do
        post :capture, referred_by_id: referrer.id, email: user.email, format: :json
        expect(response.status).to eq 404
      end
    end

    context "user already invited" do
      # Using let(:invited) { User.invite!(...) } here for some reason nulls out the object in the it blocks after
      # it is used in another block. Don't understand.
      it "should have set resource invited_by_id" do
        invited = User.invite!({ email: "#{SecureRandom.hex(8)}@example.com" })
        post :capture, referred_by_id: referrer.id, email: invited.email, format: :json
        invited = User.find(invited.id)
        expect(invited.invited_by_id).to eq referrer.id
      end
      it "should respond with 201" do
        invited = User.invite!({ email: "#{SecureRandom.hex(8)}@example.com" })
        post :capture, referred_by_id: referrer.id, email: invited.email, format: :json
        expect(response.status).to eq 201
        expect(response.content_type).to eq(Mime::JSON)
      end
      it "should send invitation to correct email" do
        perform_enqueued_jobs do
          invited = User.invite!({ email: "#{SecureRandom.hex(8)}@example.com" })
          post :capture, referred_by_id: referrer.id, email: invited.email, format: :json
          delivered_email = ActionMailer::Base.deliveries.last
          expect(delivered_email.to.first).to eq invited.email
        end
      end
      it "should send invitation with correct subject" do
        perform_enqueued_jobs do
          invited = User.invite!({ email: "#{SecureRandom.hex(8)}@example.com" })
          post :capture, referred_by_id: referrer.id, email: invited.email, format: :json
          delivered_email = ActionMailer::Base.deliveries.last
          expect(delivered_email.subject).to include("#{referrer.display_name} invited you")
        end
      end
    end

    context "new user email" do
      let(:resource_email) { "#{SecureRandom.hex(8)}@example.com" }
      it "should respond with 201" do
        post :capture, referred_by_id: referrer.id, email: resource_email, format: :json
        expect(response.status).to eq 201
        expect(response.content_type).to eq(Mime::JSON)
      end
      it "should have set resource invited_by_id" do
        post :capture, referred_by_id: referrer.id, email: resource_email, format: :json
        resource = User.find_by_email(resource_email)
        expect(resource.invited_by_id).to eq referrer.id
      end
      it "should send invitation to correct email" do
        perform_enqueued_jobs do
          post :capture, referred_by_id: referrer.id, email: resource_email, format: :json
          delivered_email = ActionMailer::Base.deliveries.last
          expect(delivered_email.to.first).to eq resource_email
        end
      end
      it "should send invitation with correct subject" do
        perform_enqueued_jobs do
          post :capture, referred_by_id: referrer.id, email: resource_email, format: :json
          delivered_email = ActionMailer::Base.deliveries.last
          expect(delivered_email.subject).to include("#{referrer.display_name} invited you")
        end
      end
    end
  end
end
