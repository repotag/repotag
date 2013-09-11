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