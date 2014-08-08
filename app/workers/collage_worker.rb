class CollageWorker
  include Sidekiq::Worker

  def perform(options = nil)
    return if options.nil?

    morsel = Morsel.find(options['morsel_id'])
    service = GenerateCollage.call morsel: morsel

    if service.valid?
      morsel.update photo:service.response
    end

    MrslWorker.perform_async(options)
  end
end
