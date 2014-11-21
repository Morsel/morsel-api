require 'spec_helper'

describe UpdateMorselTags do
  let(:summary) { 'I just ate a donut #yolo #blessed #hashtag' }
  let(:morsel) { FactoryGirl.create(:morsel, summary: summary) }

  it_behaves_like 'RequiredAttributes' do
    let(:valid_attributes) {{
      morsel: morsel
    }}
  end

  it 'should update the morsel tags based on the hashtags in the summary' do
    call_service ({
      morsel: morsel
    })

    expect_service_success
    expect(service_response).to eq(%w(blessed hashtag yolo))
  end

  context 'existing keywords' do
    before do
      morsel.tags << FactoryGirl.create(:morsel_hashtag_tag)
      morsel.tags << FactoryGirl.create(:morsel_hashtag_tag, keyword: FactoryGirl.create(:hashtag, name: 'yolo'), tagger: morsel.creator)
    end

    it 'should NOT remove any existing keywords that match the hashtags' do
      call_service ({
        morsel: morsel
      })

      expect_service_success
      expect(service_response).to eq(%w(blessed hashtag yolo))
    end

    it 'should remove any unused keywords' do
      call_service ({
        morsel: morsel
      })

      expect_service_success
      expect(service_response).to eq(%w(blessed hashtag yolo))
    end
  end
end
