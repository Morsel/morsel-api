class ContactWorker
  include Sidekiq::Worker

  def perform(options = nil)
    return if options.nil?

    CreateZendeskTicket.call(options.symbolize_keys.merge(tags: ['contact-form', 'api', Rails.env]))
  end
end
