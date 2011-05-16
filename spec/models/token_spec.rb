require 'spec_helper'

describe Token do

  context 'given a saved instance' do

    let(:token) { Factory(:token) }

    it 'should provide a list of locales for which the translations are missing' do
      token.project.locales.create :code => 'en'
      token.should have(1).missing_translation
      token.project.locales.create :code => 'de'
      token.should have(2).missing_translations
    end

  end

  it 'should create all missing translations after create' do
    project = Factory(:project)
    project.locales.create :code => 'en'
    project.locales.create :code => 'de'
    token = Factory(:token, :project => project)
    token.missing_translations.should be_empty
    token.should have(2).translations
  end
   
end
