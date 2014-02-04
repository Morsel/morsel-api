module JSONEnvelopable
  extend ActiveSupport::Concern

  private

    def render_json(data, http_status)
      render_json_envelope(data, nil, http_status)
    end

    def render_json_errors(errors, http_status)
      render_json_envelope(nil, errors, http_status)
    end

    def render_json_envelope(data, errors = nil, http_status = :ok)
      status_code = Rack::Utils.status_code(http_status)
      render json: {
        meta: {
          status: status_code,
          message: Rack::Utils::HTTP_STATUS_CODES[status_code],
        },
        errors: errors,
        data: data
        },
        status: http_status
    end
end
