require 'spec_helper'

describe "keys/index.html.erb" do
  before(:each) do
    assign(:keys, [
      stub_model(Key),
      stub_model(Key)
    ])
  end

  it "renders a list of keys" do
    render
  end
end
