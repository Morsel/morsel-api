require 'spec_helper'

describe PreparePresignedUpload do
  let(:service_class) { described_class }

  context 'invalid model specified' do
    let(:invalid_model) { FactoryGirl.create(:cuisine) }
    it 'throws an error' do
      call_service model: invalid_model

      expect_service_failure
    end
  end

  context 'Item specified' do
    let(:item) { FactoryGirl.create(:item) }
    let(:expected_keys) { ['AWSAccessKeyId', 'key', 'policy', 'signature', 'acl', 'url'] }

    it_behaves_like 'RequiredAttributes' do
      let(:valid_attributes) {{
        model: item
      }}
    end

    it 'should return the correct fields' do
      stub_aws_s3_client

      call_service model: item

      expect_service_success
      expect((service_response.keys & expected_keys).count).to eq(expected_keys.count)
    end
  end
end
