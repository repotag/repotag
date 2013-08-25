require 'spec_helper'

describe Repository do
  
  before :each do
    @repository = FactoryGirl.create(:repo_with_owner)
  end

  it "has a name" do
    repo = Repository.new
    repo.should_not be_valid
    repo.name = "test_repo"
    repo.name.should == "test_repo"
    repo.should be_valid
  end

  roles = Repotag::Application.config.role_titles.map{|role_title| ActiveSupport::Inflector.pluralize(role_title).to_s }
  roles.each do |role|
    it "returns its #{role}" do
      @repository.respond_to?(role).should == true
      @repository.send(role).should be_kind_of(Array)
    end
  end
  
  it "corresponds to a RJGit repository" do
    @repository.repository.should be_a RJGit::Repo
  end
  
  it ".filesystem_path returns a unique path where it stores its repository" do
    @repository.should respond_to(:filesystem_path)
  end
  
  describe "receiving information from servlet" do 
    
    it "receives a list of repositories" do
      repos_fixture = JSON.load("{\"https://localhost:8443/git/hond.git\":{\"name\":\"hond.git\",\"description\":\"Puppies!\",\"owner\":\"test\",\"lastChange\":\"2012-04-05T20:35:21Z\",\"hasCommits\":false,\"showRemoteBranches\":false,\"useTickets\":false,\"useDocs\":false,\"accessRestriction\":\"NONE\",\"isFrozen\":false,\"showReadme\":false,\"federationStrategy\":\"FEDERATE_THIS\",\"federationSets\":[],\"isFederated\":false,\"skipSizeCalculation\":false,\"skipSummaryMetrics\":false,\"isBare\":true,\"HEAD\":\"refs/heads/master\",\"availableRefs\":[],\"indexedBranches\":[],\"size\":\"424 b\",\"preReceiveScripts\":[],\"postReceiveScripts\":[],\"mailingLists\":[]},\"https://localhost:8443/git/konijn.git\":{\"name\":\"konijn.git\",\"description\":\"Konijntjes\",\"owner\":\"admin\",\"lastChange\":\"2012-04-05T20:35:21Z\",\"hasCommits\":false,\"showRemoteBranches\":true,\"useTickets\":false,\"useDocs\":true,\"accessRestriction\":\"NONE\",\"isFrozen\":false,\"showReadme\":true,\"federationStrategy\":\"FEDERATE_THIS\",\"federationSets\":[],\"isFederated\":false,\"skipSizeCalculation\":false,\"skipSummaryMetrics\":false,\"isBare\":true,\"HEAD\":\"refs/heads/master\",\"availableRefs\":[],\"indexedBranches\":[],\"size\":\"424 b\",\"preReceiveScripts\":[],\"postReceiveScripts\":[],\"mailingLists\":[]}}")
      @jsonrpc_client = double("jsonrpc_client") #, :request => repos)
      @jsonrpc_client.should_receive(:request).with(kind_of(String)).and_return(repos_fixture)
      repositories = @jsonrpc_client.request('LIST_REPOSITORIES')
      repositories.should be_kind_of(Hash)
      repositories.each do |url, repository|
        repository.should be_kind_of(Hash)
        ['name', 'description', 'owner'].each do |key|
          repository.should have_key(key)
          repository[key].should_not be_empty 
        end
      end
    end
  end

end
