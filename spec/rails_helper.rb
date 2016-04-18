ENV["RAILS_ENV"] = "test"

require File.expand_path("../../config/environment", __FILE__)
abort("DATABASE_URL environment variable is set") if ENV["DATABASE_URL"]

require "rspec/rails"
require "devise"
include ActiveJob::TestHelper

Dir[Rails.root.join("spec/support/**/*.rb")].sort.each { |file| require file }

module Features
  # Extend this module in spec/support/features/*.rb
  include Formulaic::Dsl
end

RSpec.configure do |config|
  config.include Features, type: :feature
  config.infer_base_class_for_anonymous_controllers = false
  config.infer_spec_type_from_file_location!
  config.use_transactional_fixtures = false
  config.include Devise::TestHelpers, type: :controller
end

ActiveRecord::Migration.maintain_test_schema!

# Allow localhost requests for capybara tests
WebMock.disable_net_connect!(:allow_localhost => true)

VCR.configure do |config|
 config.ignore_localhost = true
 config.ignore_hosts 'codeclimate.com'
 config.configure_rspec_metadata!
 #the directory where your cassettes will be saved
 config.cassette_library_dir = 'spec/vcr'
 # your HTTP request service. You can also use fakeweb, webmock, and more
 config.hook_into :webmock
end
