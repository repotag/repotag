require 'spec_helper'

describe "Repositories" do
  describe "GET /repositories" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get repositories_path
      expect(response.status).to be(302) # Not 200 because forced authentication by devise redirects
    end
  end
end
