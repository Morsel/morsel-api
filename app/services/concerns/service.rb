require 'active_model/validations'

module Service
  extend ActiveSupport::Concern

  included do
    include Virtus.model
    include ActiveModel::Validations

    attribute :response

    def self.call(*args)
      service = new(*args)
      service.response = service.call if service.valid?
      service
    end

    def self.required_attributes
      validators.select { |w| w.is_a? ActiveModel::Validations::PresenceValidator }.map(&:attributes).flatten
    end

    def attributes
      super.except :response
    end
  end
end
