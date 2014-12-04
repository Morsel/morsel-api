require 'spec_helper'

describe Search::SearchUsers do
  let(:service_params) { {query: query} }
  let(:query) { 'turd' }

  context 'query' do
    before do
      FactoryGirl.create(:user, first_name: 'TURd')
      FactoryGirl.create(:user, last_name: 'tURD')
      FactoryGirl.create(:user, username: 'turdski')
    end

    it 'should return `following`=false' do
      call_service service_params

      expect_service_success
      expect(service_response.count).to eq(3)
      expect(service_response.first['following']).to be_false
    end

    describe 'fuzzy begins with' do
      let(:query) { 'tur' }

      it 'should return `following`=false' do
        call_service service_params

        expect_service_success
        expect(service_response.count).to eq(3)
        expect(service_response.first['following']).to be_false
      end
    end

    describe 'narrowing down multiple Pauls' do
      let(:query) { 'Paul Kahan' }

      before do
        FactoryGirl.create(:user, first_name: 'Paul', last_name: 'Fehribach')
        FactoryGirl.create(:user, first_name: 'Paul', last_name: 'Kahan')

        call_service service_params
      end

      it 'should return `following`=false' do
        expect_service_success
        expect(service_response.count).to eq(1)
        expect(service_response.first['following']).to be_false
      end

      it 'should return Paul Kahan' do
        expect_service_success
        expect(service_response.count).to eq(1)
        expect(service_response.first['first_name']).to eq('Paul')
        expect(service_response.first['last_name']).to eq('Kahan')
      end
    end
  end

  context 'promoted' do
    let(:promoted_users_count) { rand(2..6) }
    let(:service_params) {{ promoted: true }}

    before do
      promoted_users_count.times { FactoryGirl.create(:user, promoted: true) }
      rand(1..3).times { FactoryGirl.create(:user) }

      call_service service_params
    end

    it 'should return the correct number of promoted users' do
      expect_service_success
      expect(service_response.count).to eq(promoted_users_count)
    end
  end

  context 'first_name' do
    let(:valid_users_count) { rand(4..6) }
    let(:service_params) {{ first_name: 'TuRD' }}

    before do
      valid_users_count.times { FactoryGirl.create(:user, first_name: 'Turd') }
      rand(1..3).times { FactoryGirl.create(:user) }

      call_service service_params
    end

    it 'should return the correct number of users w/ first_name like Turd' do
      expect_service_success
      expect(service_response.count).to eq(valid_users_count)
    end
  end

  context 'last_name' do
    let(:valid_users_count) { rand(4..6) }
    let(:service_params) {{ last_name: 'FeRG' }}

    before do
      valid_users_count.times { FactoryGirl.create(:user, last_name: 'Ferg') }
      rand(1..3).times { FactoryGirl.create(:user) }

      call_service service_params
    end

    it 'should return the correct number of users w/ last_name like Ferg' do
      expect_service_success
      expect(service_response.count).to eq(valid_users_count)
    end
  end
end
