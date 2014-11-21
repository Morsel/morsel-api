shared_examples 'RequiredAttributes' do
  context 'missing attribute' do

    described_class.required_attributes.each do |required_attribute|
      context ":#{required_attribute}" do
        it 'throws an error' do
          call_service (valid_attributes.except(required_attribute))

          expect_service_failure
          expect_service_error(required_attribute.to_s, 'can\'t be blank')
        end
      end
    end
  end
end
