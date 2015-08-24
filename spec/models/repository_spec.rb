require 'spec_helper'
require 'json'

describe Repository do

  context "instance" do
  
    before(:each) do
      @repository = FactoryGirl.create(:repository)
    end

    it_behaves_like "a model that has settings", :repository, [:default_branch, :enable_issuetracker, :enable_wiki]
    [:name, :owner].each do |attribute|
      it_behaves_like "a model that validates presence of", Repository, attribute
    end

    it "has a name unique for its owner" do
      repo = Repository.new
      repo.name = @repository.name
      repo.owner = @repository.owner
      expect(repo).to_not be_valid
      repo.name = "not#{@repository.name}"
      expect(repo).to be_valid
      repo.name = @repository.name
      repo.owner = FactoryGirl.create(:user)
      expect(repo).to be_valid
    end

    ['all', 'contributing', 'watching', 'collaborating'].each do |role|
      it "returns its #{role} users" do
        role = "#{role}_users".to_sym
        expect(@repository).to respond_to(role)
        expect(@repository.send(role)).to be_a_kind_of(Array)
      end
    end
    
    it "can have many Issues"
    
    it "can have many Milestones"
    
    it "can have many Labels"
    
    it "corresponds to a RJGit repository" do
      expect(@repository.repository).to be_a_kind_of(RJGit::Repo)
    end

    it "initializes a repository on disk when nonexistent" do
      repo = FactoryGirl.create(:repository)
      FileUtils.rm_rf(repo.filesystem_path)
      expect(repo.to_disk).to be_a_kind_of(RJGit::Repo)
    end

    it "initializes a readme" do
      @repository.initialize_readme
      expect(@repository.repository.commits).to_not be_empty
      commit = @repository.repository.commits.first
      expect(commit.message).to eq "Test commit message"
      expect(commit.actor.name).to eq @repository.owner.name
      expect(commit.actor.email).to eq @repository.owner.email
    end

    it "initializes test data" do
      @repository.populate_with_test_data
      expect(@repository.repository.commits).to_not be_empty
      commit = @repository.repository.commits.first
      expect(commit.message).to eq "Test commit message"
      expect(commit.actor.name).to eq "test"
      expect(commit.actor.email).to eq "test@repotag.org"
    end

    it ".filesystem_path returns a unique path where it stores its repository" do
      expect(@repository).to respond_to(:filesystem_path)
      expect(@repository.filesystem_path).to match /#{@repository.id}.git$/
    end

    it "converts itself to json" do
      expect(JSON.parse(@repository.to_json)).to_not be_nil
    end

  end

  context "class" do

    before do
      @repo = FactoryGirl.create(:repository)
    end

    it "initializes from request path" do
      expect(Repository.from_request_path("nota/validpath")).to be_nil
      expect(Repository.from_request_path("/nonexistent/repo")).to be_nil
      expect(Repository.from_request_path("/#{@repo.owner.username}/#{@repo.name}")).to be_a Repository
    end

    it "finds all users with a given role for a repository" do
      expect(Repository.users(@repo)).to be_empty
      user = FactoryGirl.create(:user)
      user.add_role(:watcher, @repo)
      expect(Repository.users(@repo, :watcher)).to include(user)
    end

  end
  
  context "receiving information from servlet" do 
    
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
