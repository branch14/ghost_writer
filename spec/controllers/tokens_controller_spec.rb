require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by the Rails when you ran the scaffold generator.

describe TokensController do

  def mock_token(stubs={})
    @mock_token ||= mock_model(Token, stubs).as_null_object
  end

  describe "GET index" do
    it "assigns all tokens as @tokens" do
      Token.stub(:all) { [mock_token] }
      get :index
      assigns(:tokens).should eq([mock_token])
    end
  end

  describe "GET show" do
    it "assigns the requested token as @token" do
      Token.stub(:find).with("37") { mock_token }
      get :show, :id => "37"
      assigns(:token).should be(mock_token)
    end
  end

  describe "GET new" do
    it "assigns a new token as @token" do
      Token.stub(:new) { mock_token }
      get :new
      assigns(:token).should be(mock_token)
    end
  end

  describe "GET edit" do
    it "assigns the requested token as @token" do
      Token.stub(:find).with("37") { mock_token }
      get :edit, :id => "37"
      assigns(:token).should be(mock_token)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "assigns a newly created token as @token" do
        Token.stub(:new).with({'these' => 'params'}) { mock_token(:save => true) }
        post :create, :token => {'these' => 'params'}
        assigns(:token).should be(mock_token)
      end

      it "redirects to the created token" do
        Token.stub(:new) { mock_token(:save => true) }
        post :create, :token => {}
        response.should redirect_to(token_url(mock_token))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved token as @token" do
        Token.stub(:new).with({'these' => 'params'}) { mock_token(:save => false) }
        post :create, :token => {'these' => 'params'}
        assigns(:token).should be(mock_token)
      end

      it "re-renders the 'new' template" do
        Token.stub(:new) { mock_token(:save => false) }
        post :create, :token => {}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested token" do
        Token.stub(:find).with("37") { mock_token }
        mock_token.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :token => {'these' => 'params'}
      end

      it "assigns the requested token as @token" do
        Token.stub(:find) { mock_token(:update_attributes => true) }
        put :update, :id => "1"
        assigns(:token).should be(mock_token)
      end

      it "redirects to the token" do
        Token.stub(:find) { mock_token(:update_attributes => true) }
        put :update, :id => "1"
        response.should redirect_to(token_url(mock_token))
      end
    end

    describe "with invalid params" do
      it "assigns the token as @token" do
        Token.stub(:find) { mock_token(:update_attributes => false) }
        put :update, :id => "1"
        assigns(:token).should be(mock_token)
      end

      it "re-renders the 'edit' template" do
        Token.stub(:find) { mock_token(:update_attributes => false) }
        put :update, :id => "1"
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested token" do
      Token.stub(:find).with("37") { mock_token }
      mock_token.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the tokens list" do
      Token.stub(:find) { mock_token }
      delete :destroy, :id => "1"
      response.should redirect_to(tokens_url)
    end
  end

end
