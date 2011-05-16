require File.expand_path('../../spec_helper', __FILE__)

describe CoreExtensions do

  context "Hash" do
    
    it "should provide deep_merge" do
      {}.should respond_to :deep_merge
    end
    
    it "should not break normal merge" do
      { :a => :b }.deep_merge({ :c => :d }).should == { :a => :b, :c => :d }
    end
    
    it "should perform a deep merge without conflicts" do
      hash0, hash1 = { :a => { :b => :c } }, { :a => { :d => :e } }
      hash0.deep_merge(hash1).should == { :a => { :b => :c, :d => :e } }
      hash0.deep_merge(hash1) { raise }.should == { :a => { :b => :c, :d => :e } }
    end
      
    it "should perform a deep merge with conflicts and yield block" do
      hash0, hash1 = { :a => :b }, { :a => { :c => :d } }
      hash0.deep_merge(hash1) { |result, other, key| result[key] }.should == hash0
      hash0.deep_merge(hash1) { |result, other, key| other[key] }.should == hash1
      hash0, hash1 = { :a => { :b => :c } }, { :a => :d }
      hash0.deep_merge(hash1) { |result, other, key| result[key] }.should == hash0
      hash0.deep_merge(hash1) { |result, other, key| other[key] }.should == hash1
    end

    it "should overwrite in case of conflict and no block given" do
      hash0, hash1 = { :a => { :b => :c } }, { :a => :d }
      hash0.deep_merge(hash1).should == hash1
    end
    
  end

end
