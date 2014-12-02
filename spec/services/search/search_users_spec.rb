require 'spec_helper'

describe Search::SearchUsers do
  subject(:service) { call_service(service_params) }

  let(:service_params) { {query: query} }
  let(:query) { 'turd' }

  context 'query' do
    before do
      FactoryGirl.create(:user, first_name: 'TURd')
      FactoryGirl.create(:user, last_name: 'tURD')
      FactoryGirl.create(:user, username: 'turdski')
      service
    end

    it { should be_valid }
    its('response.count') { should eq(3) }

    it 'should return `following`=false' do
      expect(service_response.first['following']).to be_false
    end

    describe 'fuzzy begins with' do
      let(:query) { 'tur' }

      it { should be_valid }
      its('response.count') { should eq(3) }

      it 'should return `following`=false' do
        expect(service_response.first['following']).to be_false
      end
    end

    describe 'narrowing down multiple Pauls' do
      let(:query) { 'Paul Kahan' }

      before do
        FactoryGirl.create(:user, first_name: 'Paul', last_name: 'Fehribach')
        FactoryGirl.create(:user, first_name: 'Paul', last_name: 'Kahan')
      end

      it { should be_valid }
      its('response.count') { should eq(1) }

      it 'should return `following`=false' do
        expect(service_response.first['following']).to be_false
      end
      it 'should return Paul Kahan' do
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
      service
    end

    it { should be_valid }
    its('response.count') { should eq(promoted_users_count) }
  end

  context 'first_name' do
    let(:valid_users_count) { rand(4..6) }
    let(:service_params) {{ first_name: 'TuRD' }}

    before do
      valid_users_count.times { FactoryGirl.create(:user, first_name: 'Turd') }
      rand(1..3).times { FactoryGirl.create(:user) }
      service
    end

    it { should be_valid }
    its('response.count') { should eq(valid_users_count) }
  end

  context 'last_name' do
    let(:valid_users_count) { rand(4..6) }
    let(:service_params) {{ last_name: 'FeRG' }}

    before do
      valid_users_count.times { FactoryGirl.create(:user, last_name: 'Ferg') }
      rand(1..3).times { FactoryGirl.create(:user) }
      service
    end

    it { should be_valid }
    its('response.count') { should eq(valid_users_count) }
  end
end
