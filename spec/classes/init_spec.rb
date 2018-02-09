require 'spec_helper'
describe 'rtm' do
  context 'with default values for all parameters' do
    it { should contain_class('rtm') }
  end
end
