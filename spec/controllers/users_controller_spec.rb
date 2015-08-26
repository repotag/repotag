require 'spec_helper'

describe UsersController, type: :controller do
    let(:user) { FactoryGirl.create(:user) }

    before do
      sign_in user
    end

    describe "PUT" do
      describe "#update" do
        let(:name){ user.name }

          context "with valid attributes" do
            before do
              put :update, :id => user.to_param, :user => {:name => "New#{name}"}
              user.reload
            end
            it_behaves_like "a controller action", {:template => nil, :layout => nil, :response => 302}
            it { expect(user.name).to eq "New#{name}" }
            it { expect(flash[:notice]).to match /successfully updated/ }
          end

          context "with invalid attributes" do
            before do
              put :update, :id => user.to_param, :user => {:name => nil}
              user.reload
            end
            it_behaves_like "a controller action", {:template => :edit}
            it { expect(flash[:alert]).to match /Name can't be blank/}
            it { expect(user.name).to eq name }
          end
      end

      describe "#update_settings" do
        let(:setting) { :notifications_as_watcher }
        let(:new_value) { user.settings[setting] == "1" ? "0" : "1" }

          context "with valid attributes" do
            before do
              put :update_settings, :user => user, :name => setting.to_s, :value => new_value
              user.reload
            end
            it { expect(user.settings[setting]).to eq new_value }
            it_behaves_like "a controller action", {:template => :settings}
          end

          context "with invalid attributes" do
            before do
              put :update_settings, :user => user, :name => "nonexistent", :value => true
              user.reload
            end
            it { expect(user.settings["nonexistent"]).to be_nil }
            it_behaves_like "a controller action", {:template => :settings}
          end
      end
    end

    describe "GET" do

      describe "#edit" do
        before do
          get :edit, id: user.to_param
        end
        it_behaves_like "a controller action", {:template => :edit}
      end

      describe "#show" do
        before do
          get :show, id: user.to_param
        end
        it_behaves_like "a controller action", {:template => :show}
      end

      describe "#settings" do
        before do
          get :settings, user: user
        end
        it_behaves_like "a controller action", {:template => :settings}
      end

    end

end