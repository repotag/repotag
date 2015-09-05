# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use Opal in this file.

Document.ready? do
  # client = this.ZeroClipboard.new(Element.find('#d_clip_button') )
	client = `new ZeroClipboard(document.getElementById('d_clip_button') )`
	
  Element.find('#public-toggle').on(:change) do |event|
    checked = event.current_target.prop 'checked'
    if checked
      HTTP.put('toggle_public', data: {repository: {public: true}})
    else
      HTTP.put('toggle_public', data: {repository: {public: false}})
    end
  end

end