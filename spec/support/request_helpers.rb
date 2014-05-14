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

    def expect_true_json_data
      expect(json_data).to eq(true)
    end

    def expect_false_json_data
      expect(json_data).to eq(false)
    end

    def expect_json_eq(json, hash)
      hash.each do |k,v|
        if json[k].is_a? Hash
          expect_json_eq(json[k], v)
        else
          expect(json[k]).to eq(v), "Expected #{k} = #{v}, got #{json[k]}"
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

    def expect_status(status)
      expect(response.status).to eq(status)
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
