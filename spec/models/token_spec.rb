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
      project = Factory(:project)
      locale = project.locales.create :code => 'en'
      project.find_or_create_tokens('this.is.a.test').last.tap do |token|
        token.translations.create! :locale_id => locale.id, :content => 'Original content.'
      end
    end
    it 'should prohibit a threeway merge with attributes provided' do
      attrs = {"en" => {"content" => "This is a test.", "count" => 1}}
      translations = token.update_or_create_all_translations(attrs)
      translation_en = translations.select { |t| t.code == 'en' } .first
      translation_en.content.should eq("Original content.")
    end
    it 'should provide its translations as a nested hash' do
      expected = { 'en' => { 'this' => { 'is' => { 'a' => { 'test' => 'Original content.' }}}}}
      token.translations_as_nested_hash.should eq(expected)
    end
  end

  context 'given a couple of tokens with translations' do
    it 'should find tokens by named scope changed_after' do
        project = Factory(:project)
      token0 = project.find_or_create_tokens('test.token.one').last
      token1 = project.find_or_create_tokens('test.token.two').last
      token2 = project.find_or_create_tokens('test.token.three').last
      locale0 = project.locales.create! :code => 'en'
      locale1 = project.locales.create! :code => 'de'
      token0.update_or_create_all_translations
      token1.update_or_create_all_translations
      token2.update_or_create_all_translations
      tokens = [ token0, token1, token2 ]
  
      now = I18n.l(Time.now, :format => :http)
      an_hour_ago = I18n.l(1.hour.ago, :format => :http)

      Token.changed_after(now).should be_empty
      Token.changed_after(an_hour_ago).should eq(tokens)
  
      Timecop.freeze(1.day.ago) do
        token3 = project.find_or_create_tokens('test.token.four').last
        token3.update_or_create_all_translations
      end
  
      project.tokens.select(&:is_childless?).count.should be(4)
      Token.changed_after(an_hour_ago).should eq(tokens)
    end
  end

  context 'named scope changed_after' do
    it 'should accept date_times and strings as well' do
      sql0 = Token.changed_after(Time.now).to_sql
      sql1 = Token.changed_after(I18n.l(Time.now, :format => :http)).to_sql 
      sql0.should eq(sql1)
    end
  end

end
