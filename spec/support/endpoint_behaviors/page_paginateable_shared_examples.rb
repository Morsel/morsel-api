shared_examples 'PagePaginateable' do
  let(:page) { 2 }
  describe 'page' do
    it 'paginates w/ `page`' do
      expected_count = paginateable_object_class.count - ((page - 1) * Settings.pagination_default_count)
      get_endpoint page: page

      expect_success
      expect_json_data_count expected_count
    end
  end

  describe 'count' do
    it 'works with `page`' do
      expected_count = rand(3..6)

      get_endpoint({
        count: expected_count,
        page: page
      })

      expect_success
      expect_json_data_count expected_count
    end
  end
end
