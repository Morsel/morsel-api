class ReportsController < ApiController
  def create
    ReportReportableWorker.perform_async(
      reporter_id: current_user.id,
      type: reportable_type,
      id: params[:id]
    )
    render_json_ok
  end

  private

  def reportable_type
    request.path.split('/').second.classify
  end
end
