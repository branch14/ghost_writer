require "spec_helper"

describe SetsController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/sets" }.should route_to(:controller => "sets", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/sets/new" }.should route_to(:controller => "sets", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/sets/1" }.should route_to(:controller => "sets", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/sets/1/edit" }.should route_to(:controller => "sets", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/sets" }.should route_to(:controller => "sets", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/sets/1" }.should route_to(:controller => "sets", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/sets/1" }.should route_to(:controller => "sets", :action => "destroy", :id => "1")
    end

  end
end
