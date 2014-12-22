require 'spec_helper'

describe Scripts::ExtractHashtagsFromMorselTitlesToSummaries do
  let(:morsel) { FactoryGirl.create(:morsel_with_hashtags, hashtags_count: hashtags_count) }
  let(:hashtags_count) { rand(2..5) }
  let(:original_summary) { morsel.summary }

  before { morsel; original_summary }

  it 'should extract the hashtags' do
    call_service
    expect_service_success
    expect(ExtractHashtags.call(text: morsel.reload.title).response).to be_empty
    expect(ExtractHashtags.call(text: morsel.reload.summary).response.count).to eq(hashtags_count)
    expect(morsel.summary.include?(original_summary)).to be_true
  end

  context 'morsel title is a hashtag' do
    let(:hashtag) { "##{Faker::Lorem.word}" }
    before do
      morsel.update title: hashtag
    end

    it 'should leave the hashtag in the title' do
      call_service
      expect_service_success
      expect(ExtractHashtags.call(text: morsel.reload.title).response.count).to eq(1)
      expect(ExtractHashtags.call(text: morsel.reload.summary).response.count).to eq(1)
      expect(morsel.summary.include?(original_summary)).to be_true
    end
  end
end
