require 'spec_helper'

describe "user_options/edit" do
  before(:each) do
    @user_option = assign(:user_option, stub_model(UserOption))
  end

  it "renders the edit user_option form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", user_option_path(@user_option), "post" do
    end
  end
end
