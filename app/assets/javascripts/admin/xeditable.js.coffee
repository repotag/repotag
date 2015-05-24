$.fn.editable.defaults.mode = 'inline';
$.fn.editable.defaults.ajaxOptions = {type: "PUT"};
$.fn.editableform.buttons = '<button type="submit" class="btn btn-primary editable-submit"><i class="fa fa-check icon-white"></i></button>
<button type="button" class="btn btn-primary editable-cancel"><i class="fa fa-times"></i></button>'

$(document).ready ->
	$('#smtp_address').editable(
		name: 'address'
		type: 'text'
		pk: 1
		url: '/admin/email/smtp'
		title: 'Enter username' )

	$('#smtp_port').editable(
		name: 'port'
		type: 'text'
		pk: 1
		url: '/admin/email/smtp'
		title: 'Enter port number' )
		
	$('#smtp_domain').editable(
		name: 'port'
		type: 'text'
		pk: 1
		url: '/admin/email/smtp'
		title: 'Enter domain' )
		
	$('#smtp_user_name').editable(
		name: 'user_name'
		type: 'text'
		pk: 1
		url: '/admin/email/smtp'
		title: 'Enter username' )
		
	$('#smtp_password').editable(
		name: 'password'
		type: 'password'
		pk: 1
		url: '/admin/email/smtp'
		title: 'Enter Password' )
	
	$('#smtp_authentication').editable(
		name: 'authentication'
		type: 'select'
		pk: 1
		url: '/admin/email/smtp'
		title: 'Select authentication mode'
		value: 'plain'
		source: ['plain', 'login', 'cram_md5'] )
		
	$('#smtp_starttls').editable(
		name: 'enable_starttls_auto'
		type: 'select'
		pk: 1
		url: '/admin/email/smtp'
		title: 'Enable StartTLS'
		value: 'true'
		source: [ 
			{ value: 0, text: 'false' }
			{ value: 1, text: 'true' } ])
	
	# General settings 
	$('#general_repo_root').editable(
		name: 'repo_root'
		type: 'text'
		pk: 1
		url: '/admin/settings/general'
		title: 'Enter root directory' )

	$('#general_default_branch').editable(
		name: 'default_branch'
		type: 'text'
		pk: 1
		url: '/admin/settings/general'
		title: 'Enter default branch' )
		
	$('#general_anonymous_access').editable(
		name: 'anonymous_access'
		type: 'select'
		pk: 1
		url: '/admin/settings/general'
		title: 'Allow Anonymous Access'
		value: 'true'
		source: [ 
			{ value: 0, text: 'false' }
			{ value: 1, text: 'true' } ]
	)
	
	$('#general_public_profiles').editable(
		name: 'public_profiles'
		type: 'select'
		pk: 1
		url: '/admin/settings/general'
		title: 'Enable Public Profiles'
		value: 'false'
		source: [ 
			{ value: 0, text: 'false' }
			{ value: 1, text: 'true' } ]
	)
	
	$('#general_enable_wikis').editable(
		name: 'enable_wikis'
		type: 'select'
		pk: 1
		url: '/admin/settings/general'
		title: 'Enable Wikis Globally'
		value: 'false'
		source: [ 
			{ value: 0, text: 'false' }
			{ value: 1, text: 'true' } ]
	)
	
	$('#general_enable_issuetracker').editable(
		name: 'enable_issuetracker'
		type: 'select'
		pk: 1
		url: '/admin/settings/general'
		title: 'Enable Issue Tracker Globally'
		value: 'false'
		source: [ 
			{ value: 0, text: 'false' }
			{ value: 1, text: 'true' } ]
	)
	
	# Authentication settings
	$('#auth_google_enabled').editable(
		name: 'google_oauth2_enabled'
		type: 'select'
		pk: 1
		url: '/admin/settings/authentication'
		title: 'Enable Google Oauth2 authentication'
		value: 'false'
		source: [ 
			{ value: 0, text: 'false' }
			{ value: 1, text: 'true' } ]
	)
	
	$('#auth_google_app_id').editable(
		name: 'google_oauth2_app_id'
		type: 'text'
		pk: 1
		url: '/admin/settings/authentication'
		title: 'Enter your Google App ID' )

	$('#auth_google_app_secret').editable(
		name: 'google_oauth2_app_secret'
		type: 'text'
		pk: 1
		url: '/admin/settings/authentication'
		title: 'Enter your Google App secret' )

	$('#auth_facebook_enabled').editable(
		name: 'facebook_enabled'
		type: 'select'
		pk: 1
		url: '/admin/settings/authentication'
		title: 'Enable Facebook Oauth2 authentication'
		value: 'false'
		source: [ 
			{ value: 0, text: 'false' }
			{ value: 1, text: 'true' } ]
		)
				
	$('#auth_facebook_app_id').editable(
		name: 'facebook_app_id'
		type: 'text'
		pk: 1
		url: '/admin/settings/authentication'
		title: 'Enter your Facebook ID' )

	$('#auth_facebook_app_secret').editable(
		name: 'facebook_app_secret'
		type: 'text'
		pk: 1
		url: '/admin/settings/authentication'
		title: 'Enter your Facebook secret' )
		
	$('#auth_github_enabled').editable(
		name: 'github_enabled'
		type: 'select'
		pk: 1
		url: '/admin/settings/authentication'
		title: 'Enable Github Oauth2 authentication'
		value: 'false'
		source: [ 
			{ value: 0, text: 'false' }
			{ value: 1, text: 'true' } ]
		)

	$('#auth_github_app_id').editable(
		name: 'github_app_id'
		type: 'text'
		pk: 1
		url: '/admin/settings/authentication'
		title: 'Enter your Github ID' )

	$('#auth_github_app_secret').editable(
		name: 'github_app_secret'
		type: 'text'
		pk: 1
		url: '/admin/settings/authentication'
		title: 'Enter your Github secret' )
		
		
	# Repository-specific settings
	$('#enable_wiki').editable(
		name: 'enable_wiki'
		type: 'select'
		pk: 1
		url: document.URL
		title: 'Enable Wiki'
		value: 'false'
		source: [ 
			{ value: 0, text: 'false' }
			{ value: 1, text: 'true' } ]
	)
	
	$('#enable_issuetracker').editable(
		name: 'enable_issuetracker'
		type: 'select'
		pk: 1
		url: document.URL
		title: 'Enable Issue tracker'
		value: 'false'
		source: [ 
			{ value: 0, text: 'false' }
			{ value: 1, text: 'true' } ]
	)

	$('#default_branch').editable(
		name: 'default_branch'
		type: 'select'
		pk: 1
		url: document.URL
		value: 'a'
		source: $('#default_branch').data('branches')
	)
	

	