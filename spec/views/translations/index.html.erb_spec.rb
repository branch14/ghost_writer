require 'spec_helper'

describe "translations/index.html.erb" do
  before(:each) do
    assign(:translations, [
      stub_model(Translation),
      stub_model(Translation)
    ])
  end

  it "renders a list of translations" do
    render
  end
end
