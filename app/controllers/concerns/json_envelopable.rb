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

  def custom_respond_with_cached_serializer(relation, serializer, context = {}, &block)
    relation_is_array = relation.respond_to? :count
    if (relation_is_array ? relation.count > 0 : relation.present?)
      custom_respond_with CachedSerializer.new(
        relation,
        serializer: serializer,
        scope: current_user,
        context: context
      ).to_json(rooted: true)
    else
      render_json (relation_is_array ? [] : {})
    end
  end

  def custom_respond_with_service(service, options = {})
    if service.valid?
      custom_respond_with service.response, options
    else
      render_json_errors service.errors
    end
  end

  def render_json_with_service(service, options = {})
    if service.valid?
      render_json service.response
    else
      render_json_errors service.errors
    end
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

  def render_json_nil
    render_json(nil)
  end
end
