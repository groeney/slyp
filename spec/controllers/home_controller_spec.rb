require "rails_helper"

RSpec.describe HomeController, type: :controller do
  describe "#feed" do
    context "user.invited?" do
      let(:user) { FactoryGirl.create(:user, :with_reslyps) }
      before do
        user.invited!
        sign_in user
      end
      it "should redirect to accept invitation path" do
        get :feed, format: :html
        expect(response).to redirect_to Rails.application.routes.url_helpers
                                             .accept_user_invitation_path(user)
      end
    end

    context "user.waitlisted?" do
      let(:user) { FactoryGirl.create(:user, :with_reslyps) }
      before do
        user.waitlisted!
        sign_in user
      end
      it "should redirect to accept invitation path" do
        get :feed, format: :html
        expect(response).to redirect_to Rails.application.routes.url_helpers
                                             .accept_user_invitation_path(user)
      end
    end
  end
end
