require 'spec_helper'

describe Api::MorselsController do
  describe Api::MorselsController::MorselParams do
    describe '.build' do
      it 'cleans the params' do
        params = ActionController::Parameters.new(
            morsel: {
              description: 'Some description',
              photo: 'Photo placeholder',
              foo: 'bar' },
            lorem: 'ipsum')
        morsels_params = Api::MorselsController::MorselParams.build(params)
        expect(morsels_params).to eq({
          description: 'Some description',
          photo: 'Photo placeholder' }.with_indifferent_access)
      end
    end
  end

end
