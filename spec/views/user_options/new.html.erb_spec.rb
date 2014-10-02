require 'spec_helper'

describe "user_options/new" do
  before(:each) do
    assign(:user_option, stub_model(UserOption).as_new_record)
  end

  it "renders new user_option form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", user_options_path, "post" do
    end
  end
end
