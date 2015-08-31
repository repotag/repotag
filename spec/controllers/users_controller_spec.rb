require 'spec_helper'

describe UsersController, type: :controller do
  let(:user) { FactoryGirl.create(:user) }

  before do
    sign_in user
  end

  it_behaves_like "it controls settings", :user

  context "authorization" do
    describe "protects update actions" do
      let(:other_user) { FactoryGirl.create(:user) }
      before do
        expect(controller).to receive(:authorize!).with(:update, other_user).and_return(false)
      end
      it { put :update, :id => other_user.to_param, :user => { :name => 'cantupdate' } }
    end
  end

  context "with an authorized user" do
     
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
    end
  
  end # Authorized user

end