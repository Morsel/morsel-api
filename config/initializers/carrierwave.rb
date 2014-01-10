CarrierWave.configure do |config|
  if Rails.env.production?
    config.storage :aws
    config.aws_bucket = Settings.aws.buckets.default
    config.aws_acl    = :public_read
    config.aws_authenticated_url_expiration = 60 * 60 * 24 * 365

    config.aws_credentials = Settings.aws.credentials
  else
    config.storage = :file
    config.enable_processing = false
  end
end
