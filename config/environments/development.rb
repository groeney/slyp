require Rails.root.join("config/smtp")
Rails.application.configure do
  config.cache_classes = false
  config.eager_load = false
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false
  config.action_mailer.raise_delivery_errors = true
  config.after_initialize do
    Bullet.enable = true
    Bullet.bullet_logger = true
    Bullet.rails_logger = true
  end
  config.active_support.deprecation = :log
  config.active_record.migration_error = :page_load
  config.assets.debug = true
  config.log_level = :info
  config.logger = Logger.new(STDOUT)
  config.assets.digest = true
  config.action_mailer.smtp_settings = SMTP_SETTINGS
  config.action_mailer.default_url_options = {
    host: ENV.fetch("APPLICATION_HOST")
  }
  config.assets.raise_runtime_errors = true
  config.action_view.raise_on_missing_translations = true
  config.action_mailer.preview_path = "#{Rails.root}/lib/mailer_previews"
end
