require 'rollbar/rails'
Rollbar.configure do |config|
  config.access_token = Settings.rollbar.access_token

  # Without configuration, Rollbar is enabled by in all environments.
  # To disable in specific environments, set config.enabled=false.
  # Here we'll disable in 'test':
  if Rails.env.test? || Rails.env.development?
    config.enabled = false
  else
    config.use_sidekiq
  end

  config.environment = Rails.env
  config.scrub_fields |= [:api_token, :token]
end
