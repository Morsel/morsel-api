class ReportReportableWorker
  include Sidekiq::Worker

  def perform(options = nil)
    return if options.nil?

    type = options['type']
    id = options['id']
    reporter = User.find options['reporter_id']

    reportable = type.constantize.find id

    CreateZendeskTicket.call(
      name: reporter.username,
      subject: "[AUTOMATED] #{type} ##{id} reported!",
      description: "#{reporter.username} (#{reporter.url}) has reported #{reportable.url}",
      tags: ['reported', 'api', Rails.env],
      type: 'incident'
    )
  end
end
