class UpdateMorselTagsWorker
  include Sidekiq::Worker

  def perform(options = nil)
    return if options.nil?

    UpdateMorselTags.call(morsel: Morsel.find(options['morsel_id']))
  end
end
