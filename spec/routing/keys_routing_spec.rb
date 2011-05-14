require "spec_helper"

describe KeysController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/keys" }.should route_to(:controller => "keys", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/keys/new" }.should route_to(:controller => "keys", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/keys/1" }.should route_to(:controller => "keys", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/keys/1/edit" }.should route_to(:controller => "keys", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/keys" }.should route_to(:controller => "keys", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/keys/1" }.should route_to(:controller => "keys", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/keys/1" }.should route_to(:controller => "keys", :action => "destroy", :id => "1")
    end

  end
end
