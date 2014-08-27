require "spec_helper"

describe UserOptionsController do
  describe "routing" do

    it "routes to #index" do
      get("/user_options").should route_to("user_options#index")
    end

    it "routes to #new" do
      get("/user_options/new").should route_to("user_options#new")
    end

    it "routes to #show" do
      get("/user_options/1").should route_to("user_options#show", :id => "1")
    end

    it "routes to #edit" do
      get("/user_options/1/edit").should route_to("user_options#edit", :id => "1")
    end

    it "routes to #create" do
      post("/user_options").should route_to("user_options#create")
    end

    it "routes to #update" do
      put("/user_options/1").should route_to("user_options#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/user_options/1").should route_to("user_options#destroy", :id => "1")
    end

  end
end
