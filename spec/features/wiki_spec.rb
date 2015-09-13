require 'spec_helper'

def get_wiki_page(user, repo, page = nil)
  get "/#{user.to_param}/#{repo.to_param}/#{page}/wiki"
end

describe 'gollum wikis' do
  let(:repo) { FactoryGirl.create(:repository) }
  let(:owner) { repo.owner }
  context 'with a valid repository path' do

    after do
      allow(repo).to receive(:wiki_enabled?).and_return_original
    end

    describe 'wiki enabled' do
      before do
        http_auth(owner.username, owner.password)
        allow(repo).to receive(:wiki_enabled?).and_return(true)
        get_wiki_page(owner, repo)
      end

      it 'shows the wiki for the repo' do
        it_behaves_like 'a controller action', {:template => nil, :layout => nil, :response => 302}
        expect(response.html).to have_text "Create New Page"
      end
    end

    describe 'wiki disabled' do
      it 'returns 404' do
        http_auth(owner.username, owner.password)
        allow(repo).to receive(:wiki_enabled?).and_return(false)
        get_wiki_page(owner, repo)
        expect(response.status).to eq 404
      end
    end

  end

  context 'with an invalid repository path' do
    it 'returns 404' do
      get "/#{user.to_param}/nonexistent/wiki"
      expect(response.status).to eq 404
    end
  end

  context 'authorization' do
    let(:user) { FactoryGirl.create(:user) }

    describe 'a public wiki' do
      before do
        repo.public = true
      end
      it 'is readable by everyone' do
        expect(GollumAuthProxy).to receive(:authorized?).with(repo, nil).and_return(:read)
        get_wiki_page(owner, repo)
      end
      it 'is not writable by everyone' do
        expect(GollumAuthProxy).to_not receive(:authorized?).with(repo, nil).and_return(:write)
        get_wiki_page(owner, repo)
      end
      it 'is writable by everyone if the wiki is publicly editable' do
        allow(repo).to receive(:settings).with(:wiki).and_return({:public_editable => true})
        expect(GollumAuthProxy).to_not receive(:authorized?).with(repo, nil).and_return(:write)
        get_wiki_page(owner, repo)
        allow(repo).to receive(:settings).with(:wiki).and_return_original
      end
    end

    describe 'a non-public wiki' do
      before do
        repo.public = false
        http_auth(user.username, user.password)
      end
      it 'is readable if the user can read the repository' do
        expect(GollumAuthProxy).to receive(:authorized?).with(repo, nil).and_return(false)
        get_wiki_page(owner, repo)
        user.add_role(:watcher, repo)
        expect(GollumAuthProxy).to receive(:authorized?).with(repo, nil).and_return(:read)
        get_wiki_page(owner, repo)
      end
      it 'is writable if the user can write the repository' do
        expect(GollumAuthProxy).to receive(:authorized?).with(repo, nil).and_return(false)
        get_wiki_page(owner, repo)
        user.add_role(:contributor, repo)
        expect(GollumAuthProxy).to receive(:authorized?).with(repo, nil).and_return(:write)
        get_wiki_page(owner, repo)
      end
    end
  end
end