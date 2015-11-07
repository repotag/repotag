require 'spec_helper'

def assert_settings(settings_form, prefix)
  # 
  settings_form.each do |label, value|
    id = value[0]
    type = value[1] ? value[1] : "input" 
    expect(page).to have_text label
    click_link("#{prefix}_#{id}")
    expect(page).to have_selector(:css, "#{type}.form-control")
    find(:css, 'button.editable-cancel').click
    expect(page).to_not have_selector(:css, "#{type}.form-control")
  end
end

feature "Admin manages settings for", :js => true do

  let(:user) { FactoryGirl.create(:user) }
  
  before do
    user.set_admin(true)
    http_auth(user.username,user.password)
  end
  
  scenario "smtp settings", :js => true do
    settings_form = {
      'Server' => ['address'],
      'Port' => ['port'],
      'Domain' => ['domain'],
      'Username' => ['user_name'],
      'Password' => ['password'],
      'Authentication' => ['authentication', 'select'],
      'Starttls' => ['starttls', 'select']
    }
    visit '/admin/email/smtp'
    assert_settings(settings_form, 'smtp')
    fill_editable('smtp_address', 'test')
    expect(Setting.get(:smtp_settings)[:address]).to eq 'test'
  end

  scenario "general settings", :js => true do
    settings_form = {
      'Repository root' => ['repo_root'],
      'Archive root' => ['archive_root'],
      'Wiki root' => ['wiki_root'],
      'Server domain' => ['server_domain'],
      'Server port' => ['server_port'],
      'Default branch' => ['default_branch'],
      'Allow anonymous access' => ['anonymous_access', 'select'],
      'Enable public profiles' => ['public_profiles', 'select'],
      'Enable wikis globally' => ['enable_wikis', 'select'],
      'Enable issue tracker globally' => ['enable_issuetracker', 'select']
    }
    visit '/admin/settings/general'
    assert_settings(settings_form, 'general')
    fill_editable('general_server_domain', 'test')
    expect(Setting.get(:general_settings)[:server_domain]).to eq 'test'
  end

  scenario "authentication settings", :js => true do
    auth = Setting.get(:authentication_settings)
    auth[:google_oauth2] = {}
    auth[:facebook] = {}
    auth[:github] = {}
    auth.save
    settings_form = {
      'Enable google authentication' => ['google_enabled', 'select'],
      'Google app id' => ['google_app_id'],
      'Google app secret' => ['google_app_secret'],
      'Enable facebook authentication' => ['facebook_enabled', 'select'],
      'Facebook id' => ['facebook_app_id'],
      'Facebook secret' => ['facebook_app_secret'],
      'Enable github authentication' => ['github_enabled', 'select'],
      'Github id' => ['github_app_id'],
      'Github secret' => ['github_app_secret']
    }
    visit '/admin/settings/authentication'
    assert_settings(settings_form, 'auth')
    fill_editable('auth_google_app_id', 'test')
    expect(Setting.get(:authentication_settings)[:google_oauth2][:google_oauth2_app_id]).to eq 'test'
  end
  
end