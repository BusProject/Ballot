require 'spec_helper'

describe "user_options/show" do
  before(:each) do
    @user_option = assign(:user_option, stub_model(UserOption))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
