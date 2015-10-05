require 'spec_helper'

describe Admin::UsersController, type: :controller do
  let(:user) { FactoryGirl.create(:user) }

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
          get :edit, :id => user.to_param
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
          get :show, :id => user.to_param
        end
        it_behaves_like "a controller action", admin_expectations({:template => :show})
      end

    end

    describe 'POST' do
      describe '#update' do
        before do
          post :update, :id => user.to_param, :user => valid_attributes_for_model(User)
        end
        it_behaves_like 'a controller action', {:template => nil, :response => 302, :redirect => '/admin/users', :layout => nil}
      end
      describe '#create' do
        before do
          post :create, :id => user.to_param, :user => valid_attributes_for_model(User)
        end
        it_behaves_like 'a controller action', {:template => nil, :response => 302, :redirect => '/admin/users', :layout => nil}
      end
    end

    describe 'DELETE' do
      describe '#destroy' do
        before do
          delete :destroy, :id => user.to_param
        end
        it_behaves_like 'a controller action', {:template => nil, :response => 302, :redirect => '/admin/users', :layout => nil}
      end
    end
  end

end