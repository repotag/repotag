$( document ).ready(function() {

	var states = ['Alabama', 'Alaska', 'Arizona', 'Arkansas', 'California',
	  'Colorado', 'Connecticut', 'Delaware', 'Florida', 'Georgia', 'Hawaii',
	  'Idaho', 'Illinois', 'Indiana', 'Iowa', 'Kansas', 'Kentucky', 'Louisiana',
	  'Maine', 'Maryland', 'Massachusetts', 'Michigan', 'Minnesota',
	  'Mississippi', 'Missouri', 'Montana', 'Nebraska', 'Nevada', 'New Hampshire',
	  'New Jersey', 'New Mexico', 'New York', 'North Carolina', 'North Dakota',
	  'Ohio', 'Oklahoma', 'Oregon', 'Pennsylvania', 'Rhode Island',
	  'South Carolina', 'South Dakota', 'Tennessee', 'Texas', 'Utah', 'Vermont',
	  'Virginia', 'Washington', 'West Virginia', 'Wisconsin', 'Wyoming'
	];

	// constructs the suggestion engine
	var engine = new Bloodhound({
	  datumTokenizer: Bloodhound.tokenizers.obj.whitespace('value'),
	  queryTokenizer: Bloodhound.tokenizers.whitespace,
	  // `states` is an array of state names defined in "The Basics"
	  local: $.map(states, function(state) { return { value: state }; })
	});

	// kicks off the loading/processing of `local` and `prefetch`
	engine.initialize();

	$('.typeahead').typeahead({
	  hint: true,
	  highlight: true,
	  minLength: 1,
	},
	{
	  name: 'states',
	  displayKey: 'value',
	  // `ttAdapter` wraps the suggestion engine in an adapter that
	  // is compatible with the typeahead jQuery plugin
	  source: engine.ttAdapter(),
	  templates: {
      empty: [
        '<div class="empty-message">',
        'No username matches found.',
        '</div>'
      ].join('\n'),
      suggestion: function(username){
        return  '<div id="user-selection">' +
                '<p><strong>' + username.value + 
								'</strong></p></div>';
      }
    }
  
	
	
	  }
	);


});