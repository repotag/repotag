require 'spec_helper'

def valid_session(user)
  env = {}
  env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(user.username, user.password)
  env
end

def git_url(repo, wiki = false)
  url = "http://#{Capybara.current_session.server.host}:#{Capybara.current_session.server.port}/git/#{repo.owner.to_param}/#{repo.to_param}"
  wiki ? "#{url}-wiki" : url
end

def clone_repo(user, repo, path, wiki = false)
  RJGit::RubyGit.clone(git_url(repo, wiki), path, :username => user.username, :password => user.password, :branch => 'refs/heads/master')
end

def do_commit(repo)
  tree = RJGit::Tree.new_from_hashmap(repo, {"newblob" => "contents"}, repo.head.tree )
  actor = RJGit::Actor.new("test", "test@repotag.org")
  commit = RJGit::Commit.new_with_tree(repo, tree, "My commit message", actor)
  repo.update_ref(commit)
  commit.message
end

describe 'grack' do
  let(:repo) { FactoryGirl.create(:repository) }
  let(:owner) { repo.owner }
  it 'returns not found for invalid path' do
    get "/git/#{owner.to_param}/norepo/git-upload-pack"
    expect(response.status).to eq 404
  end

  context 'without user' do
    it 'returns acess denied' do
      get "/git/#{owner.to_param}/#{repo.to_param}/git-upload-pack"
      expect(response.status).to eq 401
    end
  end

  context 'authorized user', :js => true do # Activate JS so we can use Capybara to get the server host/port
    let(:user){ FactoryGirl.create(:user) }
    let(:clone_path) { Dir.mktmpdir }
    before do
      user.add_role(:contributor, repo)
      user.save
      repo.populate_with_test_data
      repo.initialize_readme(true)
      allow_any_instance_of(Repository).to receive(:wiki_enabled?) { true }
    end
    after do
      remove_temp_repo(clone_path)
    end
    it 'clones the repo' do
      clone = clone_repo(user, repo, clone_path)
      expect(clone).to be_a_kind_of(RJGit::Repo)
      expect(clone.head.tree.blobs.first.data).to eq  "# This is a test repo with one directory and two files."
    end
    it 'clones the wiki' do
      clone = clone_repo(user, repo, clone_path, true)
      expect(clone).to be_a_kind_of(RJGit::Repo)
      expect(clone.head.tree.blobs.first.data).to eq "# Welcome to the #{repo.name} wiki!\nSome gollum instructions"
    end
    it 'pushes to the repo' do
      clone = clone_repo(user, repo, clone_path)
      new_message = do_commit(clone)
      expect(repo.repository.head.message).to_not eq new_message
      RJGit::RubyGit.new(clone).push('origin', ['refs/heads/master'], :username => user.username, :password => user.password)
      expect(repo.repository.head.message).to eq new_message
    end
    it 'pushes to the wiki' do
      clone = clone_repo(user, repo, clone_path, true)
      new_message = do_commit(clone)
      expect(repo.wiki.head.message).to_not eq new_message
      RJGit::RubyGit.new(clone).push('origin', ['refs/heads/master'], :username => user.username, :password => user.password)
      expect(repo.wiki.head.message).to eq new_message
    end
  end

  context 'unauthorized user' do
    let(:unauthorized) { FactoryGirl.create(:user) }
    it 'returns unauthorized' do
      valid_session(unauthorized)
      unauthorized.add_role(:watcher, repo)
      unauthorized.save
      get "/git/#{owner.to_param}/#{repo.to_param}/git-receive-pack", {}, valid_session(unauthorized)
      expect(response.status).to eq 403
    end
  end
end