require 'spec_helper'

describe Token do

  context 'given a token with two translations' do
    let(:token) do
      Factory(:token).tap do |token|
        locale_en = token.project.locales.create :code => 'en'
        locale_de = token.project.locales.create :code => 'de'
        token.translations.create :locale => locale_en, :content => 'asdf (en)'
        token.translations.create :locale => locale_de, :content => 'asdf (de)'
      end
    end
    # it 'should provide translations attributes as a hash' do
    #   token.translations_attributes.should be_instance_of(Hash)
    #   token.translations_attributes.values.size.should eq(2)
    # end
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
    it 'should threeway merge attributes provided' do
      # attrs = {"default"=>{"en"=>"This is a test."}, "count"=>{"en"=>1}}
      attrs = {"en" => {"content" => "This is a test.", "count" => 1}}
      translations = token.update_or_create_all_translations(attrs)
      translation_en = translations.select { |t| t.code == 'en' } .first
      translation_en.content.should eq("This is a test.")
    end
  end

end
