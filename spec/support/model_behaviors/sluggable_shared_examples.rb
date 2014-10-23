shared_examples 'Sluggable' do
  it { should respond_to(:cached_slug) }
end
