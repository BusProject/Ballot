require "spec_helper"

describe GuidesController do
  describe "routing" do

    it "routes to #index" do
      get("/guides").should route_to("guides#index")
    end

    it "routes to #new" do
      get("/guides/new").should route_to("guides#new")
    end

    it "routes to #show" do
      get("/guides/1").should route_to("guides#show", :id => "1")
    end

    it "routes to #edit" do
      get("/guides/1/edit").should route_to("guides#edit", :id => "1")
    end

    it "routes to #create" do
      post("/guides").should route_to("guides#create")
    end

    it "routes to #update" do
      put("/guides/1").should route_to("guides#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/guides/1").should route_to("guides#destroy", :id => "1")
    end

  end
end
