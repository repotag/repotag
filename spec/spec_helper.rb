require 'spork'
require 'simplecov'

SimpleCov.start 'rails' do
  add_filter 'app/views'
end
#uncomment the following line to use spork with the debugger
#require 'spork/ext/ruby-debug'

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.
  # This file is copied to spec/ when you run 'rails generate rspec:install'
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'capybara/rspec'
  require 'capybara/rails'
  require 'factory_girl_rails'
  require 'shoulda-matchers'

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

  RSpec.configure do |config|
    config.before(:suite) do
      DatabaseCleaner.clean_with :truncation
    end

    config.before(:each) do
      if self.class.metadata[:js]
        DatabaseCleaner.strategy = :truncation
      else
        DatabaseCleaner.strategy = :transaction
      end
      DatabaseCleaner.start
    end
    
    config.include RSpec::Rails::RequestExampleGroup, :file_path => %r(spec/features|spec/misc)
    
    config.after(:each) do
      DatabaseCleaner.clean
    end
    config.use_transactional_fixtures = false # http://weilu.github.io/blog/2012/11/10/conditionally-switching-off-transactional-fixtures/
    
    config.infer_spec_type_from_file_location!
    
    # Use color in STDOUT
    config.color = true

    # Use color not only in STDOUT but also in pagers and files
    config.tty = true
    
    # ## Mock Framework
    #
    # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
    #
    # config.mock_with :mocha
    # config.mock_with :flexmock
    # config.mock_with :rr

    # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
    config.fixture_path = "#{::Rails.root}/spec/fixtures"

    config.include Capybara::DSL # Manually mix in Capybara so we can use its methods outside the 'requests'/'features' dirs.

    config.include Devise::TestHelpers, :type => :view
    config.include Devise::TestHelpers, :type => :controller, :file_path => %r(spec/controllers) # Use :file_path because including these tests in feature specs causes conflicts/errors
    
    #config.include Rails.application.routes.url_helpers
    
    # If true, the base class of anonymous controllers will be inferred
    # automatically. This will be the default behavior in future versions of
    # rspec-rails.
    config.infer_base_class_for_anonymous_controllers = false
  end

  require "#{::Rails.root}/spec/shared_examples.rb"

  def valid_attributes_for_model(klass)
    case klass.to_s
    when 'User'
      { :email => 'bert@ernie.com',
        :username => 'berternie',
        :name => 'Bert Ernie',
        :password => 'koekje123'
        }
    when 'Repository'
      { :name => "testrepo",
        :owner => FactoryGirl.create(:user)
        }
    end
  end

  def admin_expectations(options = {})
    ({:layout => :admin}).merge(options)
  end

  def http_auth(name, password)
    if page.driver.respond_to?(:authorize)
        page.driver.browser.authorize(name, password)
    else
      if page.driver.respond_to?(:basic_auth)
        page.driver.basic_auth(name, password)
      elsif page.driver.respond_to?(:basic_authorize)
        page.driver.basic_authorize(name, password)
      elsif page.driver.respond_to?(:browser) && page.driver.browser.respond_to?(:basic_authorize)
        page.driver.browser.basic_authorize(name, password)
      else
        browser_login(name, password)
      end
    end
  end

  def browser_login(username, password)
    page.visit("http://#{ Capybara.current_session.server.host }:#{ Capybara.current_session.server.port }/")
    fill_in 'Login', with: username
    fill_in 'Password', with: password
    click_button 'Sign in'
  end
  
  def remove_temp_path(path)
    if File.exists?(path)
      FileUtils.rm_rf(path)
    else
      puts "\nWARNING: could not delete path (directory #{path} does not exist). Called by #{caller[0]}.\n"
    end
  end
end

Spork.each_run do
  # This code will be run each time you run your specs.
  FactoryGirl.reload
end