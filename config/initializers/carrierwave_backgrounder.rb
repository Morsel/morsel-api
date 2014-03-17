CarrierWave::Backgrounder.configure do |c|
  c.backend :sidekiq, queue: :carrierwave, backtrace: true
end
