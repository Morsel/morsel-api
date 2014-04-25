require 'spec_helper'

describe Tag do
  subject(:user_tag) { FactoryGirl.build(:user_tag) }

  it { should respond_to(:tagger) }
  it { should respond_to(:taggable) }

  it_behaves_like 'UserCreatable' do
    let(:user_creatable_object) { FactoryGirl.build(:user_tag) }
    let(:user) { user_creatable_object.user }
  end
end
