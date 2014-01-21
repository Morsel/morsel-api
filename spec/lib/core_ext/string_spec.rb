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
        subject(:twitter_string) { Faker::Lorem.characters(rand(140..200)).twitter_string }

        it 'truncates up to 140 characters' do
          expect(twitter_string.length).to be <= 140
        end

        it 'ends with \'... \'' do
          expect(twitter_string[-4, 4]).to eq('... ')
        end

        context 'has url' do
          subject(:url) { 'https://eatmorsel.com/turdferg/posts/123/4' }
          subject(:twitter_string_with_url) { Faker::Lorem.characters(rand(140..200)).twitter_string(url) }

          it 'truncates up to 140 characters' do
            expect(twitter_string.length).to be <= 140
          end

          it 'truncates the string without ruining the URL' do
            expect(twitter_string_with_url[-url.length, url.length]).to eq(url)
          end
        end
      end

      context 'less than 140 characters' do
        subject(:random_string) { Faker::Lorem.characters(rand(1..139)) }
        subject(:twitter_string) { random_string.twitter_string }

        it 'returns the same string' do
          expect(twitter_string).to eq(random_string)
        end
      end
    end
  end
end
