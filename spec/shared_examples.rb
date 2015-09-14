shared_examples_for "it controls settings" do |model|
  let(:instance) { FactoryGirl.create(model) }
  let(:user) { FactoryGirl.create(:user) }
  let(:route_options) { # Where to route to
    case model
    when :user
      {:user => instance}
    when :repository
      {:user_id => instance.owner.to_param, :repository_id => instance.to_param}
    else
      {:id => instance.to_param}
    end
  }

  before do
    sign_in user
  end

  context "with an unauthorized user" do

    describe "viewing settings is protected" do
      before do
        get :settings, route_options
      end
      it_behaves_like "an unauthorized controller action", false # No edit action, so pass false
    end

    describe "changing settings is protected" do
      let(:setting) { instance.class.default_settings.keys.first }
      let(:expected) { instance.settings[setting] }
      before do
        put :update_settings, route_options.merge({:name => setting.to_s, :value => expected == "1" ? "0" : "1"})
        instance.reload
      end

      it_behaves_like "an unauthorized controller action" do
        let(:value) { instance.settings[setting] }
      end
    end

  end

  context "with an authorized user" do

    before do
      ability = Ability.new(user)
      allow(Ability).to receive(:new) { ability }
      allow(ability).to receive(:can?).with(:read, instance) { true }
      allow(ability).to receive(:can?).with(:update, instance) { true }
      allow(ability).to receive(:can?).with(:manage, instance) { true }
    end

    describe "view settings" do
      before do
        get :settings, route_options
      end
      it_behaves_like "a controller action", {:template => :settings}
    end

    context "edit settings" do

      let(:setting) { instance.class.default_settings.keys.first }
      let(:new_value) { instance.settings[setting] == "1" ? "0" : "1" }
      
      context "with valid attributes" do
        before do
          put :update_settings, route_options.merge({:name => setting.to_s, :value => new_value})
          instance.reload
        end
        it { expect(instance.settings[setting]).to eq new_value }
        it_behaves_like "a controller action", {:template => :settings}
      end

      context "with invalid attributes" do
        before do
          put :update_settings, route_options.merge({:name => "nonexistent", :value => true})
          instance.reload
        end
        it { expect(instance.settings["nonexistent"]).to be_nil }
        it_behaves_like "a controller action", {:template => :settings}
      end

      after do
        allow(Ability).to receive(:new).and_call_original
      end
    end  
  end
end

shared_examples_for "a model that has settings" do |model|
  it "#{model.default_settings.keys}" do
    setting = FactoryGirl.create(model.name.downcase.to_sym).settings
    expect(setting).to be_a Setting
    expect(setting.settings).to be_a_kind_of Hash
    model.default_settings.each do |key, value|
      expect(setting.settings[key]).to eq value
    end
  end
end

shared_examples_for "a controller action" do |options|
  options ||= {}
  expectations = {
    :response => :ok,
    :content_type => 'text/html',
    :layout => :application,
    :redirect => nil,
    :template => nil
  }.merge options
  it { expect(controller.response.content_type).to eq expectations[:content_type] } unless expectations[:content_type].nil?
  it { is_expected.to respond_with expectations[:response] } unless expectations[:response].nil?
  it { is_expected.to render_with_layout expectations[:layout] } unless expectations[:layout].nil?
  it { is_expected.to redirect_to expectations[:redirect] } unless expectations[:redirect].nil?
  it { is_expected.to render_template expectations[:template] } unless expectations[:template].nil?
end

shared_examples_for "an unauthorized controller action" do |compare_value|
  it_behaves_like "a controller action", {:template => nil, :layout => nil, :response => 302, :redirect => '/'}
  it { expect(flash[:alert]).to match /not authorized/ }
  it { expect(value).to eq expected } unless compare_value == false
end