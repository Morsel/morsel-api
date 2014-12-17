require 'spec_helper'

describe Search::SearchKeywords do
  let(:service_params) { {query: query, type: type, promoted: promoted} }
  let(:query) { nil }
  let(:promoted) { nil }

  context Hashtag do
    let(:type) { 'Hashtag' }

    context 'query' do
      let(:query) { 'bless' }
      let(:expected_response_count) { rand(2..6) }

      before do
        expected_response_count.times do
          FactoryGirl.create(type.downcase.to_sym, name: 'blessed'.gsub(/./){|c| [c,c.swapcase][rand(2)] })
        end

        call_service service_params
      end

      it 'should return the correct number of matching hashtags' do
        expect_service_success
        expect(service_response.count).to eq(expected_response_count)
      end

      context 'includes `#`' do
        let(:query) { '#blessed' }

        it 'should return the correct number of matching hashtags' do
          expect_service_success
          expect(service_response.count).to eq(expected_response_count)
        end
      end
    end

    context 'promoted' do
      let(:promoted) { true }
      let(:promoted_keywords_count) { rand(2..6) }

      before do
        promoted_keywords_count.times { FactoryGirl.create(type.downcase.to_sym, promoted: true) }
        rand(1..3).times { FactoryGirl.create(type.downcase.to_sym) }

        call_service service_params
      end

      it 'should return the correct number of matching hashtags' do
        expect_service_success
        expect(service_response.count).to eq(promoted_keywords_count)
      end
    end
  end
end
