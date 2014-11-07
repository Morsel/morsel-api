require 'spec_helper'

describe ExtractHashtags do
  let(:service_class) { ExtractHashtags }

  let(:text) { 'I just ate a donut #yolo #blessed #hashtag' }

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

  context 'no text specified' do
    it 'throws an error' do
      call_service

      expect_service_failure
    end
  end
end
