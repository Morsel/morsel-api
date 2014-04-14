class CollageWorker
  include Sidekiq::Worker

  def perform(options = nil)
    return if options.nil?

    morsel = Morsel.find(options['morsel_id'])
    unless morsel.photo.present?
      collage_generator_decorated_morsel = MorselCollageGeneratorDecorator.new(morsel)
      collage_generator_decorated_morsel.generate
    end

    MrslWorker.perform_async(options)
  end
end
