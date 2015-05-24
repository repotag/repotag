$(document).ready ->
  # constructs the suggestion engine
  engine = new Bloodhound(
    datumTokenizer: Bloodhound.tokenizers.obj.whitespace('name')
    queryTokenizer: Bloodhound.tokenizers.whitespace
    prefetch: 'select_users.json')
  # kicks off the loading/processing of `local` and `prefetch`
  engine.initialize()
  $('.typeahead').typeahead {
    hint: true
    highlight: true
    minLength: 1
  },
    name: 'potential_contributors'
    source: engine.ttAdapter()
    displayKey: 'name'
  return