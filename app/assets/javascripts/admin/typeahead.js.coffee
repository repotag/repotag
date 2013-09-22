$(document).ready ->
	$('.typeahead').typeahead( 
		name: 'planets'
		local: [ "Mercury", "Venus", "Earth", "Mars", "Jupiter", "Saturn", "Uranus", "Neptune" ] )