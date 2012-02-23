# -*- coding: utf-8 -*-
require File.expand_path('../../spec_helper', __FILE__)

# GhostReader posts this as data
# {\"activerecord.attributes.chamber.key\":{\"de\":{\"default\":\"Kammer Schl\\u00fcssel\"}}}
# GhostWriter works on this
# 12:45:03 Data: activerecord.attributes.chamber.key => {"de"=>{"default"=>"Kammer Schlüssel"}}

describe Project do

  context "given a valid project with one locale" do 

    let(:project) do
      Factory(:project).tap do |project|
        project.locales.create :code => 'en'
      end
    end

    it "should be valid" do
      project.should be_valid
    end

    it "should validate presence of title" do
      project.title = nil
      project.should_not be_valid
      project.errors[:title].should_not be_empty
    end

    it 'should normalize attributes' do
      input = {"en"=>{"default"=>"This is a test.", "count"=>1}}                                
      expected = {"en" => {"content" => "This is a test.", "miss_counter" => 1}}
      normalized = project.normalize_attributes(input)
      normalized.should eq(expected)
    end

    it 'should handle missed' do
      data = {"this.is.a.test" => {"default"=>{"en"=>"This is a test."}, "count"=>{"en"=>1}}}
      expect { project.handle_missed!(:data => data) }.to change(Token, :count).by(4)
    end

    it 'should properly build aggregated translations' do
      data = {"this.is.a.test" => {"en"=>{"default"=>"This is a test.", "count"=>1}}}
      expected = {"en" => {"this" => {"is" => {"a" => {"test" => "This is a test."}}}}}
      project.handle_missed!(:data => data)
      project.find_or_create_tokens('this.is.a.test').last.translations.first.should be_active
      project.aggregated_translations.should eq(expected)

      data = {"this.is.a.2nd_test" => {"en"=>{"default"=>"Hello world.", "count"=>1}}}
      expected = {"en" => {"this" => {"is" => {"a" => {"test" => "This is a test.",
                                                       "2nd_test" => "Hello world."}}}}}
      project.handle_missed!(:data => data)
      project.aggregated_translations.should eq(expected)
    end

    it 'should handle missed from json file' do
      data = {"this.is.a.test" => {"en"=>{"default"=>"This is a test.", "count"=>1}}}
      expect { project.handle_missed! :json => data.to_json }.to change(Token, :count).by(4)
    end

    it 'should nicely find or create tokens by full key' do
      tokens = project.find_or_create_tokens('this.is.a.test')
      tokens.size.should eq(4)
      tokens.map(&:key).should eq(%w(this is a test))
      tokens.map(&:ancestry_depth).should eq([0, 1, 2, 3])
      # TODO postgres increases ids
      #tokens.map(&:ancestry).should eq([nil] + %w(1 1/2 1/2/3))
      tokens.map(&:full_key).should eq(%w(this this.is this.is.a this.is.a.test))
    end

    it 'should suppress inactive translations' do
      tokens = project.find_or_create_tokens('this.is.a.test')
      tokens.last.update_or_create_all_translations
      expected = {'en' => {}}
      project.aggregated_translations.should eq(expected)
    end

    it 'should store translations for other locales if key already exists' do
      project.locales.create :code => 'es'

      data = {"this.is.a.test" => {"en"=>{"default"=>"This is a test.", "count"=>1}}}
      project.handle_missed! :data => data

      data = {"this.is.a.test" => {"es"=>{"default"=>"This test is spanish.", "count"=>1}}}
      project.handle_missed! :data => data

      hash = project.find_or_create_tokens('this.is.a.test').last.translations_as_nested_hash
      hash['es']['this']['is']['a']['test'].should == 'This test is spanish.'
    end

    it 'should gracefully handle failing validations' do
      data = {
        "this.is.a.test1" =>  {"en"=>{"default"=>"Valid 1."}},
        ".this.is.a.test2" => {"en"=>{"default"=>"Invalid by leading dot."}},
        "this.i s.a.test3" => {"en"=>{"default"=>"Invalid by space."}},
        "this.is.a.test4" =>  {"en"=>{"default"=>"Valid 2."}}
      }
      project.handle_missed! :data => data
    end

    #pending "should provide a list of remaining locales" do
    #end

    #pending "should accept nested attributes for locales" do
    #end

  end

  context 'given a project with some data' do

    let(:project) do
      Factory(:project).tap do |project|
        en = project.locales.create :code => 'en'
        de = project.locales.create :code => 'de'
        token0 = project.find_or_create_tokens('this.is.a.test').last
        token1 = project.find_or_create_tokens('this.is.another.test').last
        token0.update_or_create_all_translations({
          'en' => { 'content' => 'This is a test.' },
          'de' => { 'content' => 'Dies ist ein Test.' }
        })
        token1.update_or_create_all_translations({
          'en' => { 'content' => 'This is a mean test, it contains a ".' },
          'de' => { 'content' => 'Dies ist ein anderer Test, mit Komma.' }
        })
      end
    end

    # http://tools.ietf.org/html/rfc4180
    it 'should nicely boil down to csv' do
      expected = <<-EOB
this.is.a.test,"This is a test.","Dies ist ein Test."
this.is.another.test,"This is a mean test, it contains a \"\".","Dies ist ein anderer Test, mit Komma."
      EOB
      project.to_csv.should eq(expected)
    end

    it 'should nicely strip down hashes of tokens' do
      project.tokens.last.translations.first.update_attribute(:content, nil)
      expected = {"de"=>{"this"=>{"is"=>{"a"=>{"test"=>"Dies ist ein Test."}, "another"=>{"test"=>"Dies ist ein anderer Test, mit Komma."}}}}, "en"=>{"this"=>{"is"=>{"a"=>{"test"=>"This is a test."}}}}}
      project.aggregated_translations.should eq(expected)
    end

    it 'should nicly reset counters to zero' do
      project.locales.first.translations.first.update_attribute(:miss_counter, 42)
      expect { project.send(:perform_reset_counters!) }.should_not raise_error
      project.translations.map(&:miss_counter).uniq.should eq([0])
    end

    it 'should nicely normalize attributes' do
      attrs = {"de"=>{"default"=>"Do not remind"}}
      expected = {'de'=>{'content'=>'Do not remind'},'en'=>{}}
      project.normalize_attributes(attrs).should eq(expected)
    end

  end
end
