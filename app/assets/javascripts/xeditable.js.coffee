$.fn.editable.defaults.mode = 'inline';
$.fn.editable.defaults.ajaxOptions = {type: "PUT"};
$.fn.editableform.buttons = '<button type="submit" class="btn btn-primary editable-submit"><i class="fa fa-check icon-white"></i></button>
<button type="button" class="btn btn-primary editable-cancel"><i class="fa fa-times"></i></button>'
	
$(document).ready ->
	# User settings
	
	$('#notifications_as_watcher').editable(
		name: 'notifications_as_watcher'
		type: 'select'
		pk: 1
		url: 'update_settings'
		title: 'Receive notifications for repositories you are watching'
		value: 'true'
		source: [ 
			{ value: 0, text: 'false' }
			{ value: 1, text: 'true' } ]
	)
	
	$('#notifications_as_collaborator').editable(
		name: 'notifications_as_collaborator'
		type: 'select'
		pk: 1
		url: 'update_settings'
		title: 'Receive notifications for repositories you are collaborating on'
		value: 'true'
		source: [ 
			{ value: 0, text: 'false' }
			{ value: 1, text: 'true' } ]
	)

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