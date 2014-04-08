require 'spec_helper'

describe 'Core Extensions' do
  describe 'String' do
    describe '#normalize' do
      it 'normalizes a unicode string' do
        unicode_string = "e\xCC\x81"
        expect(unicode_string.length).to eq(2)
        expect(unicode_string.normalize.length).to eq(1)
      end
    end

    describe '#twitter_string' do
      context 'greater than 140 characters' do
        let(:twitter_string) { Faker::Lorem.characters(rand(145..200)).twitter_string('some_url') }

        it 'truncates up to 140 characters' do
          expect(twitter_string.length).to be <= 140
        end

        it 'ends with \'... \'' do
          expect(twitter_string[-27, 27]).to eq('... some_url via @eatmorsel')
        end

        context 'has url' do
          let(:url) { 'https://eatmorsel.com/turdferg/posts/123/4' }
          let(:twitter_string_with_url) { Faker::Lorem.characters(rand(140..200)).twitter_string(url) }

          it 'truncates up to 140 characters' do
            expect(twitter_string.length).to be <= 140
          end

          it 'truncates the string without ruining the URL' do
            url_with_via = "#{url} via @eatmorsel"
            expect(twitter_string_with_url[-url_with_via.length, url_with_via.length]).to eq(url_with_via)
          end
        end
      end

      context 'less than 140 characters' do
        let(:random_string) { Faker::Lorem.characters(rand(1..120)) }
        let(:twitter_string) { random_string.twitter_string('some_url') }

        it 'returns the same string' do
          expect(twitter_string).to eq("#{random_string} some_url via @eatmorsel")
        end
      end
    end
  end
end
