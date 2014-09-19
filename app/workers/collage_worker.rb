class CollageWorker
  include Sidekiq::Worker

  def perform(options = nil)
    return if options.nil?

    morsel = Morsel.find(options['morsel_id'])
    service = GenerateCollage.call morsel: morsel

    morsel.update photo: service.response if service.valid?

    MrslWorker.perform_async(options)
  end
end
