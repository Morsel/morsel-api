require 'spec_helper'

describe ShortenURL do
  let(:url) { 'https://eatmorsel.com/test' }
  let(:expected_response) { 'https://mrsl.co/test' }

  it_behaves_like 'RequiredAttributes' do
    let(:valid_attributes) {{
      url: url
    }}
  end

  it 'should return the correct url' do
    stub_bitly_client

    call_service url: url

    expect_service_success
    expect(service_response).to eq(expected_response)
  end
end
