require 'spec_helper'

describe "sets/show.html.erb" do
  before(:each) do
    @set = assign(:set, stub_model(Set))
  end

  it "renders attributes in <p>" do
    render
  end
end
