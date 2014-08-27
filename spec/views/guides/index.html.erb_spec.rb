require 'spec_helper'

describe "guides/index" do
  before(:each) do
    assign(:guides, [
      stub_model(Guide),
      stub_model(Guide)
    ])
  end

  it "renders a list of guides" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
