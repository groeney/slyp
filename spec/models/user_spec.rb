require "rails_helper"

RSpec.describe User, type: :model do
  context "associations" do
    it { is_expected.to have_many :user_slyps }
    it { is_expected.to have_many :slyps }
    it { is_expected.to have_many :reslyps }
    it { is_expected.to have_many :friendships }
    it { is_expected.to have_many :friends }
  end
end
