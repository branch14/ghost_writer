require 'spec_helper'

describe "Translations" do
  
  describe "GET /api/<api_key>/translations" do
    it "should respond with success" do
      project = Factory(:project)
      get api_translations_path(:api_key => project.api_key)
      response.status.should be(200) # success
    end
    it "should respond with not found when api_key is garbage" do
      expect do
        get '/api/invalid+api_key+here/translations'
      end.to raise_error(ActionController::RoutingError)
    end
    it "should not even build the path when api_key is garbage" do
      expect do
        api_translations_path(:api_key => "invalid+api_key+here")
      end.to raise_error(ActionController::RoutingError)
    end
  end

  describe "POST /api/<api_key>/translations" do
    let(:project) { Factory(:project) }

    it "should respond with redirect" do
      post api_translations_path(:api_key => project.api_key)
      response.status.should be(302) # redirect
    end

    it "should simply work" do
      data = {'simple' => 'nothing special here'}
      post api_translations_path(:api_key => project.api_key, :data => data.to_json)
      response.status.should be(302) # redirect
    end

    it "should simply work 2" do
      data = {'with.weird_characters' => 'copy & paste'}
      post api_translations_path(:api_key => project.api_key, :data => data.to_json)
      response.status.should be(302) # redirect
    end

    it "should simply work 3" do
      data = {'with.interpolation' => '%{interpol}'}
      post api_translations_path(:api_key => project.api_key, :data => data.to_json)
      response.status.should be(302) # redirect
    end

    # it "should fork to import when structure is native" do
    #   data = {'this' => {'is' => {'a' => 'test'}}}
    #   post api_translations_path(:api_key => project.api_key, :data => data.to_json,
    #                              :structure => 'native')
    #   assigns(:import).should be_true
    #   response.status.should be(302)
    # end
  end

end
