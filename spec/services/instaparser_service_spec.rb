require "rails_helper"
RSpec.describe InstaparserService do
  describe ".fetch" do
    context "valid params" do
      it "returns a correctly structured hash", :vcr do
        result = described_class.fetch("https://www.farnamstreetblog.com/2014/02/quotable-kierkegaard/")
        expect(result[:slyp_type]).to eq "article"
        expect(result[:title]).to eq "26 Musings from Kierkegaard"
        expect(result[:display_url]).to eq "https://www.farnamstreetblog.com/wp-content/uploads/2014/02/Kierkegaard_quote.jpeg"
        expect(result[:favicon]).to eq "http://www.google.com/s2/favicons?domain=farnamstreetblog.com"
        expect(result[:site_name]).to eq "farnamstreetblog.com"
      end
    end
  end
end