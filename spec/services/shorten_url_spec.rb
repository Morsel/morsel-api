require 'spec_helper'

describe ShortenURL do
  let(:service_class) { ShortenURL }

  let(:url) { 'https://eatmorsel.com/test' }
  let(:expected_response) { 'https://mrsl.co/test' }

  it 'should return the correct url' do
    stub_bitly_client

    call_service url: url

    expect_service_success
    expect(service_response).to eq(expected_response)
  end

  context 'no url specified' do
    it 'throws an error' do
      call_service

      expect_service_failure
    end
  end
end
