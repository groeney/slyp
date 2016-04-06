source "https://rubygems.org"

ruby "2.3.0"

gem "searchkick"
gem "sendgrid-ruby"
gem "mail"
gem "autoprefixer-rails"
gem "bourbon", "~> 4.2.0"
gem "coffee-rails", "~> 4.1.0"
gem "delayed_job_active_record"
gem "flutie"
gem "high_voltage"
gem "jquery-rails"
gem "neat", "~> 1.7.0"
gem "newrelic_rpm", ">= 3.9.8"
gem "normalize-rails", "~> 3.0.0"
gem "pg"
gem "puma"
gem "rack-canonical-host"
gem "rails", "~> 4.2.5.2"
gem "recipient_interceptor"
gem "sass-rails", "~> 5.0"
gem "simple_form"
gem "title"
gem "uglifier"
gem "devise"
gem "diffbot-ruby-client", :git => "git://github.com/diffbot/diffbot-ruby-client.git"
gem "omniauth-google-oauth2"
gem "omniauth-facebook"
gem "active_model_serializers", "~> 0.10.0.rc3"
gem "rails-backbone"
gem "validate_url"
gem "browserify-rails"
gem "sanitize"

group :development do
  gem "quiet_assets"
  gem "refills"
  gem "spring"
  gem "spring-commands-rspec"
  gem "web-console"
  gem "rails_best_practices"
  gem "rubocop"
end

group :development, :test do
  gem "awesome_print"
  gem "bullet"
  gem "bundler-audit", require: false
  gem "dotenv-rails"
  gem "factory_girl_rails"
  gem "pry-byebug"
  gem "pry-rails"
  gem "rspec-rails", "~> 3.4.0"
  gem "faker"
  gem "vcr"
end

group :test do
  gem "database_cleaner"
  gem "formulaic"
  gem "launchy"
  gem "shoulda-matchers"
  gem "simplecov", require: false
  gem "timecop"
  gem "webmock"
end

group :staging, :production do
  gem "rails_stdout_logging"
  gem "rack-timeout"
  gem "rack-wwwhisper"
  gem "rails_12factor"
end
