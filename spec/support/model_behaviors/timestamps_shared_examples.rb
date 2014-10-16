shared_examples 'Timestamps' do
  it { should respond_to(:created_at) }
  it { should respond_to(:updated_at) }
end
