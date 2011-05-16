require 'spec_helper'

describe Locale do

  context 'on class level' do

    it 'should provide a list of available locales' do
      Locale.available.should be_an_instance_of(Hash)
      Locale.available.should_not be_empty
    end

  end

  context 'given an initialized instance'do

    let(:locale) { Factory.build(:locale) }

  end

  context 'given a saved instance'do

    let(:locale) { Factory(:locale) }

  end

end
