module PhotoUploadableSerializerAttributes
  extend ActiveSupport::Concern

  included do
    attributes :photos
  end
end
