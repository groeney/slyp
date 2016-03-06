require "rails_helper"

RSpec.describe Slyp, type: :model do
  context "validations" do
    it { is_expected.to validate_presence_of :url }
  end
end
