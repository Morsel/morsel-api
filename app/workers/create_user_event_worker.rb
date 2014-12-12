class CreateUserEventWorker
  include Sidekiq::Worker

  def perform(options = nil)
    return if options.nil?

    CreateUserEvent.call(options)
  end
end
