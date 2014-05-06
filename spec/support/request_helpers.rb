module Requests
  module JsonHelpers
    def json
      @json ||= JSON.parse(response.body)
    end

    def json_data
      json['data']
    end

    def json_errors
      json['errors']
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

    def api_key_for_user(user)
      "#{user.id}:#{user.authentication_token}"
    end

    def test_photo
      Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/morsels/morsel.png')))
    end

    def expect_success
      expect(response).to be_success
    end

    def expect_failure
      expect(response).to_not be_success
    end

    # Creates [get|post|delete|put]_endpoint methods
    self.class_eval do
      [:get, :post, :delete, :put].each do |_action|
        define_method :"#{_action}_endpoint" do |_params = {}|
          if defined?(current_user) && current_user.present?
            send(_action, endpoint, _params.merge(api_key: api_key_for_user(current_user), format: :json))
          else
            send(_action, endpoint, _params.merge(format: :json))
          end
        end
      end
    end
  end
end
