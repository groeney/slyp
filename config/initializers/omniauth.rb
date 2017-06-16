Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, ENV['FACEBOOK_APP_ID'], ENV['FACEBOOK_SECRET'],
    client_options: {
      site: 'https://graph.facebook.com/v2.6',
      authorize_url: "https://www.facebook.com/v2.6/dialog/oauth"
    }
end