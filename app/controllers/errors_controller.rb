class ErrorsController < ApiController
  def routing
    message = "No route matches [#{request.method}] #{request.path}"
    render_json_errors({ api: [message] }, :not_found)
    Rollbar.warning(message)
  end
end
