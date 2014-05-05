MorselApp::Application.config.action_mailer.default_url_options = { host: Settings.morsel.web_url }

MorselApp::Application.config.action_mailer.smtp_settings = {
  address:   'smtp.mandrillapp.com',
  port:      587,
  user_name: Settings.mandrill.user_name,
  password:  Settings.mandrill.api_key # Mandrill allows using an api_key instead of a password
}

MandrillMailer.configure do |config|
  config.api_key = Settings.mandrill.api_key
end
