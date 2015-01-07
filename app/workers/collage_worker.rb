class CollageWorker
  include Sidekiq::Worker

  sidekiq_retry_in do |count|
    2
  end

  def perform(options = nil)
    return if options.nil?

    morsel = Morsel.find(options['morsel_id'])

    if morsel.items.map(&:photo_processing).uniq.include?(true)
      # photos still processing, retry job
      raise RuntimeError.new('item photos still processing')
    end

    service = GenerateCollage.call morsel: morsel

    morsel.update photo: service.response if service.valid?

    MrslWorker.perform_async(options)
  end
end
