require 'spec_helper'

describe HomeController do
  it 'returns a 200!' do
    get 'index'
    response.response_code.should == 200
  end
end
