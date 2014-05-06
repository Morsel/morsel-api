shared_examples 'TimelinePaginateable' do
  describe 'max_id' do
    it 'returns results up to and including max_id' do
      expected_count = rand(3..6)
      max_id = paginateable_object_class.first.id + expected_count - 1

      get_endpoint  max_id: max_id

      expect_success
      expect(json_data.count).to eq(expected_count)
      expect(json_data.first['id']).to eq(max_id)
    end
  end

  describe 'since_id' do
    it 'returns results since since_id' do
      expected_count = rand(3..6)
      since_id = paginateable_object_class.last.id - expected_count

      get_endpoint  since_id: since_id

      expect_success
      expect(json_data.count).to eq(expected_count)
      expect(json_data.last['id']).to eq(since_id + 1)
    end
  end

  describe 'count' do
    it 'defaults to 20' do
      get_endpoint

      expect_success
      expect(json_data.count).to eq(20)
    end

    it 'limits the result' do
      expected_count = rand(3..6)

      get_endpoint  count: expected_count

      expect_success
      expect(json_data.count).to eq(expected_count)
    end

    it 'works with the other parameters' do
      expected_count = rand(3..6)

      get_endpoint  count: expected_count,
                    max_id: paginateable_object_class.last.id

      expect_success
      expect(json_data.count).to eq(expected_count)
    end
  end
end
