require "spec_helper"

describe RepositoriesController do
  describe "routing" do

    it "routes to #index" do
      expect(get("/repositories")).to route_to("repositories#index")
    end

  end
end
