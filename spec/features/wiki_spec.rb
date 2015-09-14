require 'spec_helper'

def wiki_contents
  "Welcome to the "
end

def my_wiki_path(user, repo, page = nil)
  "/#{user.to_param}/#{repo.to_param}/wiki/#{page}"
end

def get_wiki_page(user, repo, page = nil)
  visit my_wiki_path(user, repo, page)
end

feature 'gollum wikis' do
  let(:repo) { FactoryGirl.create(:repository) }
  let(:owner) { repo.owner }

  describe 'wiki disabled' do
    it 'returns 404' do
      allow(repo).to receive(:wiki_enabled?) { false }
      http_auth(owner.username, owner.password)
      get_wiki_page(owner, repo)
      expect(page).to have_text "Not Found"
      allow(repo).to receive(:wiki_enabled?).and_call_original
    end
  end

  context 'with an invalid repository path' do
    it 'returns 404' do
      get "/#{owner.to_param}/nonexistent/wiki"
      expect(response.status).to eq 404
    end
  end

  context 'authorization', :js => true do
    before do
      allow_any_instance_of(Repository).to receive(:wiki_enabled?) { true }
      repo.initialize_readme(true)
    end

    context 'a public wiki' do
      before do
        repo.public = true
        repo.save
      end
      it 'is readable by everyone' do
        get_wiki_page(owner, repo, "README")
        expect(page).to have_text(wiki_contents)
      end

      it 'is writable by everyone if the wiki is publicly editable' do
        get_wiki_page(owner, repo)
        expect(page).to have_text("no-edit mode")
        allow_any_instance_of(Repository).to receive(:settings).and_return(Repository.default_settings.merge({:wiki => {:public_editable => true}}))
        get_wiki_page(owner, repo)
        expect(page).to have_text("Create New Page")
        allow_any_instance_of(Repository).to receive(:settings).with(:wiki).and_call_original
      end
    end

    context 'a non-public wiki' do
      let(:user) { FactoryGirl.create(:user) }
      before do
        repo.public = false
        repo.save
      end
        context 'with a non-authorized user' do
          before do
            http_auth(user.username, user.password)
          end
          it 'has no access to the wiki' do
            get_wiki_page(owner, repo, "README")
            expect(current_path).to eq '/'
          end
        end

        context 'with a watching user' do
          before do
            user.add_role(:watcher, repo)
            user.save
            http_auth(user.username, user.password)
          end

          feature "user can logout from the wiki" do
            scenario "by clicking link in navbar" do
              click_link user.name
              all(".fa-sign-out").last.click
              expect(current_path).to eq new_user_session_path
            end
          end

          it 'can read the wiki' do
            get_wiki_page(owner, repo, "README")
            expect(current_path).to eq my_wiki_path(owner, repo, "README")
            expect(page).to have_text(wiki_contents)
          end

          it 'cannot write the wiki' do
            get_wiki_page(owner, repo)
            expect(page).to have_text "no-edit"
          end
        end

        context 'with a contributing user' do
          before do
            user.add_role(:contributor, repo)
            user.save
            http_auth(user.username, user.password)
          end
          it 'can write the wiki' do
            get_wiki_page(owner, repo)
            expect(page).to have_text "Create New Page"
            fill_in "gollum-editor-body", :with => "Test"
            click_button "Save"
            expect(repo.wiki.head.actor.name).to eq user.name
            expect(repo.wiki.head.actor.email).to eq user.email
          end
        end
    end
  end
end