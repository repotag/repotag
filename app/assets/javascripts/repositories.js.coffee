# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

root = exports ? this

root.getSubDirs = (element) ->
	repo_id = $('.tree-container').data("repo-id")
	$.ajax "/repositories/#{repo_id}/get_children",
	type: 'GET'
	dataType: 'json'
	data: "path=#{element.data('path')}"
	error: (jqXHR, textStatus, errorThrown) ->
		$('body').append "AJAX Error: #{textStatus}"
	success: (data, textStatus, jqXHR) ->
		# $('body').append "Successful AJAX call: #{data}"
		root.expandTree(element, data)


root.expandTree = (element, data) ->

	subTreeHtml = ''
	for i in [0...data['dirs'].length]
		subTreeHtml += '<li>'
		subTreeHtml += "<label for='folder#{i}'> #{data['dirs']['path']}</label>"
		subTreeHtml += "<input type='checkbox' id='folder#{i}' data-path='#{data['dirs']['path']}' class='dirs'/>"
		subTreeHtml += "<ol>"
		subTreeHtml += "</ol>"		
		
	for i in [0...data['files'].length]
		subTreeHtml += "<li class='file'>"
		subTreeHtml += "<a href=''>#{data['files'][i]['path']}</a>"
		subTreeHtml += '</li>'

	console.log(subTreeHtml)
	
	$("#subtree0").html subTreeHtml
	# $("#subtree#{element.data('folder-id')}").html subTreeHtml

$(document).ready ->
	$('input:checkbox').change( (event) -> 
		dir = $(this)
		console.log(dir)
		#dir = event.target
		root.getSubDirs(dir) if this.checked )
		
