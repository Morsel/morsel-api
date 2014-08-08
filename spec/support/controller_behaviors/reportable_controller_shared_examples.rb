shared_examples 'ReportableController' do
  describe 'POST /reportable/:id/report' do
    let(:endpoint) { "#{reportable_route}/#{reportable.id}/report" }

    it 'reports the Reportable' do
      post_endpoint

      expect_success
    end
  end
end
