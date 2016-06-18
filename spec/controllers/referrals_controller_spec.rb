require "rails_helper"

RSpec.describe ReferralsController, type: :controller do
  render_views
  describe "#new" do
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
  describe "#capture" do
    let(:referrer) { FactoryGirl.create(:user) }
    it "is missing referred_by_id, so should redirect to root_path" do
      post :capture, email: referrer.email, format: :html
      expect(response).to redirect_to root_path
    end
    it "is invalid referred_by_id, so should redirect to root_path" do
      post :capture, referred_by_id: 0, format: :html
      expect(response).to redirect_to root_path
    end
    it "is invalid email, so should redirect to root_path" do
      post :capture, referred_by_id: referrer.id, email: "invalid_example", format: :html
      expect(response).to redirect_to root_path
    end
    it "should redirect to accept invitation" do
      resource_email = "valid@example.com"
      post :capture, referred_by_id: referrer.id, email: resource_email, format: :html
      resource = User.find_by_email(resource_email)
      expect(response.redirect_url).to include Rails.application.routes.url_helpers
                                                    .accept_user_invitation_path(resource)
    end
    it "should have set resource invited_by_id" do
      resource_email = "valid@example.com"
      post :capture, referred_by_id: referrer.id, email: resource_email, format: :html
      resource = User.find_by_email(resource_email)
      expect(resource.invited_by_id).to eq referrer.id
    end
  end
end
