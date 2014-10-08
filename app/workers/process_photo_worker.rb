class ProcessPhotoWorker < ::CarrierWave::Workers::ProcessAsset
  def perform(*args)
    set_args(*args) if args.present?

    super(*args)
    record = constantized_resource.find id
    run_callback record, :after_processing_success
  end

  def run_callback(record, callback)
    decorated_record = PhotoProcessableDecorator.new(record)
    if decorated_record.respond_to?(callback)
      Rails.logger.debug "Running photo processing callback: #{callback} for #{decorated_record.class} ##{decorated_record.id}"
      decorated_record.send(callback)
    else
      Rails.logger.debug "Unable to run photo processing callback: #{callback} for #{decorated_record.class} ##{decorated_record.id}"
    end
  end
end
