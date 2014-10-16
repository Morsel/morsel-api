shared_examples 'Paranoia' do
  it { should respond_to(:deleted_at) }
  its(:paranoid?) { should be_true }
end
