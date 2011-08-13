require File.expand_path('../../spec_helper', __FILE__)

describe Project do

  context "given a valid project with one locale" do 

    let(:project) { Factory(:project).tap { |p| p.locales.create :code => 'en' } }

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
      expect { project.handle_missed2!(:data => data) }.to change(Token, :count).by(4)
    end

    it 'should properly build aggregated translations' do
      data = {"this.is.a.test" => {"default"=>{"en"=>"This is a test."}, "count"=>{"en"=>1}}}
      expected = {"en" => {"this" => {"is" => {"a" => {"test" => "This is a test."}}}}}
      project.handle_missed2!(:data => data)
      project.aggregated_translations2.should eq(expected)

      data = {"this.is.a.2nd_test" => {"default"=>{"en"=>"Hello world."}, "count"=>{"en"=>1}}}
      expected = {"en" => {"this" => {"is" => {"a" => {"test" => "This is a test.",
                                                       "2nd_test" => "Hello world."}}}}}
      project.handle_missed2!(:data => data)
      project.aggregated_translations2.should eq(expected)
    end

    it 'should handle missed from json file' do
      data = {"this.is.a.test" => {"default"=>{"en"=>"This is a test."}, "count"=>{"en"=>1}}}
      expect { project.handle_missed2! :json => data.to_json }.to change(Token, :count).by(4)
    end

    it 'should nicely find or create tokens by full key' do
      tokens = project.find_or_create_tokens('this.is.a.test')
      tokens.size.should eq(4)
      tokens.map(&:key).should eq(%w(this is a test))
      tokens.map(&:ancestry_depth).should eq([0, 1, 2, 3])
      tokens.map(&:ancestry).should eq([nil] + %w(1 1/2 1/2/3))
      tokens.map(&:full_key).should eq(%w(this this.is this.is.a this.is.a.test))
    end

    #pending "should provide a list of remaining locales" do
    #end

    #pending "should accept nested attributes for locales" do
    #end

  end
end
