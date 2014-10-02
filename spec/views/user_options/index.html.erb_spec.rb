require 'spec_helper'

describe "user_options/index" do
  before(:each) do
    assign(:user_options, [
      stub_model(UserOption),
      stub_model(UserOption)
    ])
  end

  it "renders a list of user_options" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
