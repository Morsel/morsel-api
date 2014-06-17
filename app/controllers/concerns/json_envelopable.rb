module JSONEnvelopable
  extend ActiveSupport::Concern

  def custom_respond_with(*resources, &block)
    options = resources.extract_options!

    if options[:meta]
      options[:meta].merge! json_meta
    else
      options[:meta] = json_meta
    end

    respond_with(*(resources << options), &block)
  end

  private

  def json_meta
    {
      status: response.status,
      message: response.message
    }
  end

  def render_json(data, http_status = :ok)
    render_json_envelope(data, nil, http_status)
  end

  def render_json_ok
    render_json 'OK'
  end

  def render_json_errors(errors, http_status = :unprocessable_entity)
    render_json_envelope(nil, errors, http_status)
  end

  def render_json_envelope(data, errors = nil, http_status = :ok)
    status_code = Rack::Utils.status_code(http_status)
    render json: {
            meta: {
              status: status_code,
              message: Rack::Utils::HTTP_STATUS_CODES[status_code]
            },
            errors: errors,
            data: data
            },
           status: http_status
  end
end
