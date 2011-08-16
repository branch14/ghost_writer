require 'spec_helper'

describe Translation do

  describe 'given a simple translation' do
    let(:translation) { Factory(:translation) }
    it 'should set itself inactive if it defaults' do
      translation.update_attribute(:content, 'Something else.')
      translation.should be_active
      translation.update_attribute(:content, translation.token.full_key)
      translation.should_not be_active
    end
    it 'should set itself active if it does not default' do
      translation.update_attribute(:content, translation.token.full_key)
      translation.should_not be_active
      translation.update_attribute(:content, 'Something else.')
      translation.should be_active
    end
    it 'should reset content to token.full_key if content.blank?' do
      translation.token.full_key.should_not be_blank
      translation.update_attribute(:content, '')
      translation.content.should eq(translation.token.full_key)
    end
  end

end
