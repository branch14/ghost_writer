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
    it "should respond with redirect" do
      project = Factory(:project)
      post api_translations_path(:api_key => project.api_key)
      response.status.should be(302) # redirect
    end
  end

end
