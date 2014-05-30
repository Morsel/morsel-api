class ActivityWorker
  include Sidekiq::Worker

  def perform(options = nil)
    return if options.nil?
    CreateActivity.call(options)
  end
end
