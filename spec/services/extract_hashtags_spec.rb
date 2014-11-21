require 'spec_helper'

describe ExtractHashtags do
  let(:text) { 'I just ate a donut #yolo #blessed #hashtag' }

  it_behaves_like 'RequiredAttributes' do
    let(:valid_attributes) {{
      text: text
    }}
  end

  it 'should extract hashtags from text' do
    call_service ({
      text: text
    })

    expect_service_success
    expect(service_response).to eq(%w(blessed hashtag yolo))
  end

  context 'duplicate hashtags in text' do
    before { text << ' #hashtag #hashtag' }
    it 'should not return duplicates' do
      call_service ({
        text: text
      })

      expect_service_success
      expect(service_response).to eq(%w(blessed hashtag yolo))
    end
  end
end
