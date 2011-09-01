require File.expand_path('../../spec_helper', __FILE__)

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
      input = {"default"=>{"en"=>"This is a test."}, "count"=>{"en"=>1}}                                
      expected = {"en" => {"content" => "This is a test.", "miss_counter" => 1}}
      normalized = project.normalize_attributes(input)
      normalized.should eq(expected)
    end

    it 'should handle missed' do
      data = {"this.is.a.test" => {"default"=>{"en"=>"This is a test."}, "count"=>{"en"=>1}}}
      expect { project.handle_missed!(:data => data) }.to change(Token, :count).by(4)
    end

    it 'should properly build aggregated translations' do
      data = {"this.is.a.test" => {"default"=>{"en"=>"This is a test."}, "count"=>{"en"=>1}}}
      expected = {"en" => {"this" => {"is" => {"a" => {"test" => "This is a test."}}}}}
      project.handle_missed!(:data => data)
      project.find_or_create_tokens('this.is.a.test').last.translations.first.should be_active
      project.aggregated_translations.should eq(expected)

      data = {"this.is.a.2nd_test" => {"default"=>{"en"=>"Hello world."}, "count"=>{"en"=>1}}}
      expected = {"en" => {"this" => {"is" => {"a" => {"test" => "This is a test.",
                                                       "2nd_test" => "Hello world."}}}}}
      project.handle_missed!(:data => data)
      project.aggregated_translations.should eq(expected)
    end

    it 'should handle missed from json file' do
      data = {"this.is.a.test" => {"default"=>{"en"=>"This is a test."}, "count"=>{"en"=>1}}}
      expect { project.handle_missed! :json => data.to_json }.to change(Token, :count).by(4)
    end

    it 'should nicely find or create tokens by full key' do
      tokens = project.find_or_create_tokens('this.is.a.test')
      tokens.size.should eq(4)
      tokens.map(&:key).should eq(%w(this is a test))
      tokens.map(&:ancestry_depth).should eq([0, 1, 2, 3])
      tokens.map(&:ancestry).should eq([nil] + %w(1 1/2 1/2/3))
      tokens.map(&:full_key).should eq(%w(this this.is this.is.a this.is.a.test))
    end

    it 'should suppress inactive translations' do
      tokens = project.find_or_create_tokens('this.is.a.test')
      tokens.last.update_or_create_all_translations
      # FIXME should be empty
      expected = {'en' => {'this' => {'is' => {'a' => {}}}}}
      project.aggregated_translations.should eq(expected)
    end

    it 'should nicly handly json' do
      json = "{\"share\":{\"count\":{\"pt\":1,\"en\":1}},\"layouts.application.header.player.next\":{\"count\":{\"pt\":1,\"en\":1}},\"layouts.application.header.player.play\":{\"count\":{\"pt\":1,\"en\":1}},\"nested_profiles.profiles.about.about\":{\"count\":{\"pt\":1,\"en\":1}},\"layouts.application.header.player.previous\":{\"count\":{\"pt\":1,\"en\":1}}}"
      # TODO should not throw an error
      project.handle_missed!(:json => json)
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
          'en' => { 'content' => 'This is another test.' },
          'de' => { 'content' => 'Dies ist ein anderer Test, mit Komma.' }
        })
      end
    end

    # http://tools.ietf.org/html/rfc4180
    it 'should nicely boil down to csv' do
      expected = <<-EOB
this.is.a.test,"This is a test.","Dies ist ein Test."
this.is.another.test,"This is another test.","Dies ist ein anderer Test, mit Komma."
      EOB
      project.to_csv.should eq(expected)
    end

  end

end
