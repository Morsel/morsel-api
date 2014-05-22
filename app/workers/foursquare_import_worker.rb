class FoursquareImportWorker
  include Sidekiq::Worker

  def perform(options = nil)
    return if options.nil?
    ImportFoursquareVenue.call(place: Place.find(options['place']['id']))
  end
end
