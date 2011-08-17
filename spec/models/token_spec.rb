require 'spec_helper'

describe Token do

  context 'given a root token' do
    let(:token) { Factory(:token) }
    it 'should nicely set the full_key' do
      token.full_key.should eq(token.key)
    end
  end

  context 'given a deeply nested token' do
    let(:token) { Factory(:project).find_or_create_tokens('deeply.nested.token').last }
    it 'should nicely set the full_key' do
      token.full_key.should eq('deeply.nested.token')
    end
  end

  context 'given a token with two translations' do
    let(:token) do
      Factory(:token).tap do |token|
        locale_en = token.project.locales.create :code => 'en'
        locale_de = token.project.locales.create :code => 'de'
        token.translations.create :locale => locale_en, :content => 'asdf (en)'
        token.translations.create :locale => locale_de, :content => 'asdf (de)'
      end
    end
    it 'should provide translations by code as a hash' do
      tbc = token.translations_by_code
      tbc.should be_instance_of(Hash)
      tbc.keys.sort.should eq(%w(de en))
    end
  end

  context 'given a token with two missing translations' do
    let(:token) do
      Factory(:token).tap do |token|
        locale_en = token.project.locales.create :code => 'en'
        locale_de = token.project.locales.create :code => 'de'
      end
    end
    it 'should report on missing translations' do
      token.should have(2).missing_locales
      token.missing_locales.should eq(token.project.locales)
      token.translations.create!(:locale => token.missing_locales.first)
      token.should have(1).missing_locale
      token.missing_locales.should eq([token.project.locales.last])
    end
    it 'should create translations for missing locales' do
      token.should have(2).missing_locales
      token.update_or_create_all_translations
      token.should have(0).missing_locales
    end
  end

  context 'given a token with an inactive translation' do
    let(:token) do
      Factory(:token).tap do |token|
        locale = token.project.locales.create! :code => 'en'
        token.translations.create! :locale_id => locale.id, :content => ''
      end
    end
    it 'should do a threeway merge with attributes provided' do
      attrs = {"en" => {"content" => "This is a test.", "count" => 1}}
      translations = token.update_or_create_all_translations(attrs)
      translation_en = translations.select { |t| t.code == 'en' } .first
      translation_en.content.should eq("This is a test.")
    end
  end

  context 'given a token with an active translation' do
    let(:token) do
      Factory(:token).tap do |token|
        locale = token.project.locales.create :code => 'en'
        token.translations.create! :locale_id => locale.id, :content => 'Original content.'
      end
    end
    it 'should prohibit a threeway merge with attributes provided' do
      attrs = {"en" => {"content" => "This is a test.", "count" => 1}}
      translations = token.update_or_create_all_translations(attrs)
      translation_en = translations.select { |t| t.code == 'en' } .first
      translation_en.content.should eq("Original content.")
    end
  end

end
