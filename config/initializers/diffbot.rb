require "diffbot"
Rails.application.config.diffbot_client = Diffbot::APIClient.new do |config|
  config.token = ENV["DIFFBOT_TOKEN"]
end
