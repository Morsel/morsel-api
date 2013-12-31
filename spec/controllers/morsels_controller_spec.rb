require 'spec_helper'

describe MorselsController do
  describe MorselsController::MorselParams do
    describe '.build' do
      it 'cleans the params' do
        params = ActionController::Parameters.new(
            morsel: {
              description: 'Some description',
              user_id: 123,
              foo: 'bar' },
            lorem: 'ipsum')
        morsels_params = MorselsController::MorselParams.build(params)
        expect(morsels_params).to eq({ description: 'Some description', user_id: 123 }.with_indifferent_access)
      end
    end
  end

end
