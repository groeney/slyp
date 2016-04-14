require "rails_helper"

RSpec.describe BetaRequest, type: :model do
  subject { FactoryGirl.create(:beta_request) }
  it { should validate_uniqueness_of(:email).with_message("has already been submitted.") }
end
