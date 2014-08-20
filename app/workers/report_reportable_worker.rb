class ReportReportableWorker
  include Sidekiq::Worker

  def perform(options = nil)
    return if options.nil?

    type = options['type']
    id = options['id']
    reporter = User.find options['reporter_id']

    reportable = type.constantize.find id

    CreateZendeskTicket.call(
      subject: "[#{Rails.env}] #{type} ##{id} reported!",
      description: "#{reporter.username} (#{reporter.url}) has reported #{reportable.url}",
      tags: ['reported', 'api']
    )
  end
end
