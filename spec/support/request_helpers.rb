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
  end
end
