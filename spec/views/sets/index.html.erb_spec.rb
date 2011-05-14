require 'spec_helper'

describe "sets/index.html.erb" do
  before(:each) do
    assign(:sets, [
      stub_model(Set),
      stub_model(Set)
    ])
  end

  it "renders a list of sets" do
    render
  end
end
