require 'spec_helper'

describe "guides/new" do
  before(:each) do
    assign(:guide, stub_model(Guide).as_new_record)
  end

  it "renders new guide form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", guides_path, "post" do
    end
  end
end
