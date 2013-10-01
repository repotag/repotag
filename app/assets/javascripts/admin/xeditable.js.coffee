$.fn.editable.defaults.mode = 'inline';
$.fn.editable.defaults.ajaxOptions = {type: "PUT"};
$.fn.editableform.buttons = '<button type="submit" class="btn btn-primary btn-xs editable-submit"><i class="icon-ok icon-white"></i></button>
<button type="button" class="btn btn btn-xs editable-cancel"><i class="icon-remove"></i></button>'

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
			
	$('#general_repo_root').editable(
		name: 'repo_root'
		type: 'text'
		pk: 1
		url: '/admin/settings/general'
		title: 'Enter root directory' )
		
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
	
	$('#auth_google_enabled').editable(
		name: 'google_oauth2_enabled'
		type: 'checklist'
		url: '/admin/settings/authentication'
		source: {true: 'true'}
		emptytext: 'false' )
	
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
		type: 'checklist'
		url: '/admin/settings/authentication'
		source: {true: 'true'}
		emptytext: 'false' )