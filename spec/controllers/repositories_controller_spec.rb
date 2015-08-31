require 'spec_helper'

describe RepositoriesController, type: :controller do
  let(:repo) { FactoryGirl.create(:repository) }
  let(:owner) { repo.owner }
  it_behaves_like "it controls settings", :repository

  context "authorization" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      sign_in user
    end
    describe "protects update actions" do
      before do
        expect(controller).to receive(:authorize!).with(:update, repo).and_return(false)
      end
      it { patch :update, :id => repo.to_param, :user_id => owner.to_param, :repository => { :name => 'cantupdate' } }
      it { put :add_collaborator, :repository_id => repo.to_param, :user_id => owner.to_param, :username => user.username, :role => "watcher", :format => :json }
      it { put :remove_collaborator, :repository_id => repo.to_param, :user_id => owner.to_param, :collaborator_id => user.id, :role => "watcher" }
      it { get :potential_users, :repository_id => repo.to_param, :user_id => owner.to_param, :format => :json }
    end
  end

  context "with an authorized user" do
    before do
      sign_in owner
    end

    describe "GET" do
      describe "#index" do
        before do
          get :index, :user_id => owner.to_param, :id => repo.to_param
        end
        it_behaves_like "a controller action", {:template => :index}
      end

      describe "#edit" do
        before do
          get :edit, :user_id => owner.to_param, :id => repo.to_param
        end
        it_behaves_like "a controller action", {:template => :edit}
      end

      describe "#new" do
        before do
          get :new, :user_id => owner.to_param
        end
        it_behaves_like "a controller action", {:template => :new}
      end
    
      describe "#show" do
        before do
          allow_any_instance_of(RJGit::Repo).to receive(:valid?).and_return(true)
          allow(repo).to receive(:invalid?).and_return(false)
          get :show, :user_id => owner.to_param, :id => repo.to_param
        end
        it_behaves_like "a controller action", {:template => :show}
        after do
          allow(repo).to receive(:invalid?).and_call_original
          allow_any_instance_of(RJGit::Repo).to receive(:valid?).and_call_original
        end
      end

      describe "#select_users" do
        before do
          get :potential_users, :user_id => owner.to_param, :repository_id => repo.to_param, :format => :json
        end
        it_behaves_like "a controller action", {:template => nil, :content_type => 'application/json', :layout => nil}
      end
    end
  end

end