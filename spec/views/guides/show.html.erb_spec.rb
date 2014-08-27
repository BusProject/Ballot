require 'spec_helper'

describe "guides/show" do
  before(:each) do
    @guide = assign(:guide, stub_model(Guide))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
