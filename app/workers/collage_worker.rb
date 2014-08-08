class CollageWorker
  include Sidekiq::Worker

  def perform(options = nil)
    return if options.nil?

    GenerateCollage.call morsel: Morsel.find(options['morsel_id'])

    MrslWorker.perform_async(options)
  end
end
