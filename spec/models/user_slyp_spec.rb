require "rails_helper"

RSpec.describe UserSlyp, type: :model do
  context "associations" do
    it { is_expected.to belong_to :slyp }
    it { is_expected.to belong_to :user }
    it { is_expected.to have_many :reslyps }
  end
end
