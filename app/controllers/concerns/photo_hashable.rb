module PhotoHashable
  extend ActiveSupport::Concern

  # active_interaction only allows uploading File or Tempfile, so the UploadedFile used by CarrierWave is converted to a Hash then recreated
  def photo_hash(params)
    if params
      {
        type: params.content_type,
        head: params.headers,
        filename: params.original_filename,
        tempfile: params.tempfile
      }
    end
  end
end
