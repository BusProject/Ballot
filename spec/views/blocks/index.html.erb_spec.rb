require 'spec_helper'

describe "blocks/index" do
  before(:each) do
    assign(:blocks, [
      stub_model(Block),
      stub_model(Block)
    ])
  end

  it "renders a list of blocks" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
