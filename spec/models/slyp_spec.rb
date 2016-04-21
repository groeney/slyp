require "rails_helper"

RSpec.describe Slyp, type: :model do
  context "validations" do
    it { is_expected.to validate_presence_of :url }
    it { is_expected.to have_many :user_slyps }
    it { is_expected.to have_many :users }
  end

  context "slyp already exists", :vcr do
    let(:url) { "http://www.wired.com/2016/04/magic-leap-vr/" }
    let(:slyp_1) { Slyp.fetch(url) }

    it "should return correct slyp" do
      slyp_2 = Slyp.fetch(url)

      expect(slyp_2).to eq(slyp_1)
    end

    it "should not create duplicate slyp" do
      query_params = "?foo=foo&bar=bar"
      slyp_2 = Slyp.fetch(url + query_params)

      expect(slyp_1).to eq(slyp_2)
    end
  end

  context "slyp exists but not complete", :vcr do
    let(:url) { "https://www.facebook.com/berniesanders/videos/1031395530248784/" }
    let(:slyp_1) { Slyp.create({:url => url}) }

    it "should update slyp with complete data" do
      expect(slyp_1.complete?).to be false
      slyp_2 = Slyp.fetch(url)
      slyp_1 = Slyp.find_by({:url => url})
      expect(slyp_1.complete?).to be true
    end
  end
end
