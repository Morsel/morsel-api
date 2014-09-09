shared_examples 'TimelinePaginateable' do
  describe 'max_id' do
    it 'returns results up to and including max_id' do
      pending 'pagination_key != :id' if pagination_key != :id

      expected_count = rand(3..6)
      max_id = paginateable_object_class.first.id + expected_count - 1

      params = (defined?(additional_params) && additional_params.present?) ? additional_params : {}
      params.merge!({ max_id: max_id })
      get_endpoint params

      expect_success
      expect_json_data_count expected_count
      expect_first_json_data_eq('id' => max_id)
    end
  end

  describe 'since_id' do
    it 'returns results since since_id' do
      pending 'pagination_key != :id' if pagination_key != :id

      expected_count = rand(3..6)
      since_id = paginateable_object_class.last.id - expected_count

      params = (defined?(additional_params) && additional_params.present?) ? additional_params : {}
      params.merge!({ since_id: since_id })
      get_endpoint params

      expect_success
      expect_json_data_count expected_count
      expect_last_json_data_eq('id' => (since_id + 1))
    end
  end

  describe 'before_date' do
    it 'returns results before before_date' do
      pending 'pagination_key == :id' if pagination_key == :id

      expected_count = rand(3..6)
      before_date_epoch = paginateable_object_class.first[pagination_key].to_i + expected_count

      params = (defined?(additional_params) && additional_params.present?) ? additional_params : {}
      params.merge!({ before_date: before_date_epoch })
      get_endpoint params

      expect_success
      expect_json_data_count expected_count
      expect(DateTime.parse(json_data.first[pagination_response_key.to_s]).to_i).to eq(before_date_epoch - 1)
    end
  end

  describe 'after_date' do
    it 'returns results after after_date' do
      pending 'pagination_key == :id' if pagination_key == :id

      expected_count = rand(3..6)
      after_date_epoch = paginateable_object_class.last[pagination_key].to_i - expected_count

      params = (defined?(additional_params) && additional_params.present?) ? additional_params : {}
      params.merge!({ after_date: after_date_epoch })
      get_endpoint params

      expect_success
      expect_json_data_count expected_count
      expect(DateTime.parse(json_data.last[pagination_response_key.to_s]).to_i).to eq(after_date_epoch + 1)
    end
  end

  describe 'count' do
    it 'defaults to 20' do
      params = (defined?(additional_params) && additional_params.present?) ? additional_params : {}
      get_endpoint params

      expect_success
      expect_json_data_count 20
    end

    it 'limits the result' do
      expected_count = rand(3..6)

      params = (defined?(additional_params) && additional_params.present?) ? additional_params : {}
      params.merge!({ count: expected_count })
      get_endpoint params

      expect_success
      expect_json_data_count expected_count
    end

    it 'works with the other parameters' do
      expected_count = rand(3..6)

      params = (defined?(additional_params) && additional_params.present?) ? additional_params : {}
      params.merge!({
        count: expected_count,
        max_id: paginateable_object_class.last.id
      })
      get_endpoint params

      expect_success
      expect_json_data_count expected_count
    end
  end
end
