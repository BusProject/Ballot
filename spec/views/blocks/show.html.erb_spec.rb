require 'spec_helper'

describe "blocks/show" do
  before(:each) do
    @block = assign(:block, stub_model(Block))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
