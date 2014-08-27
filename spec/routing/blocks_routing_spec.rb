require "spec_helper"

describe BlocksController do
  describe "routing" do

    it "routes to #index" do
      get("/blocks").should route_to("blocks#index")
    end

    it "routes to #new" do
      get("/blocks/new").should route_to("blocks#new")
    end

    it "routes to #show" do
      get("/blocks/1").should route_to("blocks#show", :id => "1")
    end

    it "routes to #edit" do
      get("/blocks/1/edit").should route_to("blocks#edit", :id => "1")
    end

    it "routes to #create" do
      post("/blocks").should route_to("blocks#create")
    end

    it "routes to #update" do
      put("/blocks/1").should route_to("blocks#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/blocks/1").should route_to("blocks#destroy", :id => "1")
    end

  end
end
