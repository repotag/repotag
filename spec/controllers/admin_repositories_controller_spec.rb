require 'spec_helper'

describe Admin::RepositoriesController, type: :controller do
  let(:repo) { FactoryGirl.create(:repository) }

  context "with an admin user" do
    let(:admin) { FactoryGirl.create(:admin_role).user }

    before do
      sign_in admin
      expect(controller).to receive(:verify_admin).and_call_original
      expect(controller.current_user).to receive(:admin?).at_least(:once).and_call_original
    end

    describe "GET" do
      describe "#index" do
        before do
          get :index
        end
        it_behaves_like "a controller action", admin_expectations({:template => :index})
      end

      describe "#edit" do
        before do
          get :edit, :id => repo.id
        end
        it_behaves_like "a controller action", admin_expectations({:template => :edit})
      end

      describe "#new" do
        before do
          get :new
        end
        it_behaves_like "a controller action", admin_expectations({:template => :new})
      end
    
      describe "#show" do
        before do
          get :show, :id => repo.id
        end
        it_behaves_like "a controller action", {:response => 302, :redirect => /\/.+\/.+/, :layout => nil}
      end

    end

    describe 'POST' do
      describe '#update' do
        before do
          post :update, :id => repo.id
        end
        it_behaves_like 'a controller action', {:template => nil, :response => 302, :redirect => /\/.+\/.+/, :layout => nil}
      end
    end

    describe 'PUT' do
      [:archive, :unarchive].each do |action|
        describe "##{action.to_s}" do
          before do
            allow_any_instance_of(RJGit::Repo).to receive(:valid?) { true }
            allow(Setting).to receive(:get).with(:general_settings).and_return({:archive_root => "test"})
            allow(Tarchiver::Archiver).to receive(action) { true }
            put action, :repository_id => repo.id
          end
          it_behaves_like 'a controller action', {:template => nil, :response => 302, :redirect => /\/admin\/repositories/, :layout => nil}
          after do
            allow(Tarchiver::Archiver).to receive(action).and_call_original
            allow(Setting).to receive(:get).with(:general_settings).and_call_original
            allow_any_instance_of(RJGit::Repo).to receive(:valid?).and_call_original
          end
        end
      end
    end

    describe 'DELETE' do
      describe '#destroy' do
        before do
          delete :destroy, :id => repo.id
        end
        it_behaves_like 'a controller action', {:template => nil, :response => 302, :redirect => '/admin/repositories', :layout => nil}
      end
    end
  end

end