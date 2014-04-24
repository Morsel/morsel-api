require 'spec_helper'

describe Keyword do
  subject(:keyword) { FactoryGirl.build(:keyword) }

  it { should respond_to(:name) }
end
