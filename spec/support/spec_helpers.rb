module SpecHelpers
  def json
    @json
  end

  def json_data
    json['data']
  end

  def json_errors
    json['errors']
  end

  def expect_true_json_data
    expect(json_data).to eq(true)
  end

  def expect_false_json_data
    expect(json_data).to eq(false)
  end

  def expect_json_eq(json, hash)
    hash.each do |k,v|
      k_s = k.to_s
      if json[k_s].is_a? Hash
        expect_json_eq(json[k_s], v)
      else
        expect(json[k_s]).to eq(v), "Expected #{k_s} = #{v}, got #{json[k_s]}"
      end
    end
  end

  def expect_json_data_eq(hash)
    expect_json_eq(json_data, hash)
  end

  def expect_first_json_data_eq(hash)
    expect_json_eq(json_data.first, hash)
  end

  def expect_last_json_data_eq(hash)
    expect_json_eq(json_data.last, hash)
  end

  def expect_json_data_count(count)
    expect(json_data.count).to eq(count)
  end

  def expect_json_keys(json, obj, keys)
    keys.each do |key|
      expect(json[key]).to eq(obj[key])
    end
  end

  def expect_nil_json_keys(json, keys)
    keys.each do |key|
      expect(json[key]).to be_nil
    end
  end

  def expect_record_not_found_error
     expect_base_error('Record not found')
  end

  def expect_missing_param_error_for_param(param)
    expect_api_error("param is missing or the value is empty: #{param}")
  end

  def expect_first_error(key, error)
    expect(json_errors[key].first).to eq(error)
  end

  def expect_api_error(error)
    expect_first_error('api', error)
  end

  def expect_base_error(error)
    expect_first_error('base', error)
  end

  def api_key_for_user(user)
    "#{user.id}:#{user.authentication_token}"
  end

  def test_photo
    Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/morsels/morsel.png')))
  end

  def pagination_key
    @pagination_key ||= defined?(paginateable_key) ? paginateable_key : :id
  end

  def pagination_response_key
    @pagination_response_key ||= defined?(paginateable_response_key) ? paginateable_response_key : pagination_key
  end

  def expect_success
    expect(response).to be_success
  end

  def expect_failure
    expect(response).to_not be_success
  end

  def expect_status(status)
    expect(response.status).to eq(status)
  end

  def call_service(*args)
    @service = service_class.call(*args)
  end

  def service_valid?
    @service.valid?
  end

  def service_response
    @service.response
  end

  def service_errors
    @service.errors
  end

  def expect_service_success
    expect(service_valid?).to be_true
  end

  def expect_service_failure
    expect(service_valid?).to be_false
  end

  def expect_service_error(key, error)
    expect(service_errors[key].first).to eq(error)
  end

  # Creates [get|post|delete|put]_endpoint methods
  self.class_eval do
    [:get, :post, :delete, :put].each do |http_method|
      define_method :"#{http_method}_endpoint" do |endpoint_params = {}|
        if defined?(current_user) && current_user.present?
          send(http_method, endpoint, endpoint_params.merge(api_key: api_key_for_user(current_user), format: :json))
        else
          send(http_method, endpoint, endpoint_params.merge(format: :json))
        end
        @json = JSON.parse(response.body)
      end
    end
  end
end
