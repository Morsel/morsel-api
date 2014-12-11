CarrierWave.configure do |config|
  if Rails.env.production? || Rails.env.staging?
    config.storage :aws
    config.aws_bucket = Settings.aws.buckets.assets
    config.aws_acl    = :public_read
    config.aws_authenticated_url_expiration = 60 * 60 * 24 * 365

    config.aws_credentials = Settings.aws.credentials
  elsif Rails.env.development?
    config.storage = :file
  else
    config.storage = :file
    config.enable_processing = false
  end
end
