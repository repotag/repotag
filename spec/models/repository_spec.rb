require 'spec_helper'

describe Repository do
  
  before(:each) do
    @repository = FactoryGirl.create(:repository)
  end

  it "has a name" do
    repo = Repository.new
    expect(repo).to_not be_valid
    repo.name = "test_repo"
    repo.owner = @repository.owner
    expect(repo.name).to eq "test_repo"
    expect(repo).to be_valid
  end

  roles = Repotag::Application.config.role_titles.map{|role_title| ActiveSupport::Inflector.pluralize(role_title).to_s }
  roles.each do |role|
    it "returns its #{role}" do
      expect(@repository).to respond_to(role)
      expect(@repository.send(role)).to be_a_kind_of(Array)
    end
  end
  
  it "should have an owner" do  
    expect(@repository.owner).to be_a User
  end
  
  it "can have many Issues"
  
  it "can have many Milestones"
  
  it "can have many Labels"
  
  it "corresponds to a RJGit repository" do
    expect(@repository.repository).to be_a_kind_of(RJGit::Repo)
  end
  
  it ".filesystem_path returns a unique path where it stores its repository" do
    expect(@repository).to respond_to(:filesystem_path)
  end
  
  describe "receiving information from servlet" do 
    
    it "receives a list of repositories" do
      repos_fixture = JSON.load("{\"https://localhost:8443/git/hond.git\":{\"name\":\"hond.git\",\"description\":\"Puppies!\",\"owner\":\"test\",\"lastChange\":\"2012-04-05T20:35:21Z\",\"hasCommits\":false,\"showRemoteBranches\":false,\"useTickets\":false,\"useDocs\":false,\"accessRestriction\":\"NONE\",\"isFrozen\":false,\"showReadme\":false,\"federationStrategy\":\"FEDERATE_THIS\",\"federationSets\":[],\"isFederated\":false,\"skipSizeCalculation\":false,\"skipSummaryMetrics\":false,\"isBare\":true,\"HEAD\":\"refs/heads/master\",\"availableRefs\":[],\"indexedBranches\":[],\"size\":\"424 b\",\"preReceiveScripts\":[],\"postReceiveScripts\":[],\"mailingLists\":[]},\"https://localhost:8443/git/konijn.git\":{\"name\":\"konijn.git\",\"description\":\"Konijntjes\",\"owner\":\"admin\",\"lastChange\":\"2012-04-05T20:35:21Z\",\"hasCommits\":false,\"showRemoteBranches\":true,\"useTickets\":false,\"useDocs\":true,\"accessRestriction\":\"NONE\",\"isFrozen\":false,\"showReadme\":true,\"federationStrategy\":\"FEDERATE_THIS\",\"federationSets\":[],\"isFederated\":false,\"skipSizeCalculation\":false,\"skipSummaryMetrics\":false,\"isBare\":true,\"HEAD\":\"refs/heads/master\",\"availableRefs\":[],\"indexedBranches\":[],\"size\":\"424 b\",\"preReceiveScripts\":[],\"postReceiveScripts\":[],\"mailingLists\":[]}}")
      @jsonrpc_client = double("jsonrpc_client") #, :request => repos)
      expect(@jsonrpc_client).to receive(:request).with(kind_of(String)).and_return(repos_fixture)
      repositories = @jsonrpc_client.request('LIST_REPOSITORIES')
      expect(repositories).to be_a_kind_of(Hash)
      repositories.each do |url, repository|
        expect(repository).to be_a_kind_of(Hash)
        ['name', 'description', 'owner'].each do |key|
          expect(repository).to have_key(key)
          expect(repository[key]).to_not be_empty 
        end
      end
    end
  end

end
