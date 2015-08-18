class MandrilWorker
  include Sidekiq::Worker

  def perform(options = nil)
    return if options.nil?        
  end
end