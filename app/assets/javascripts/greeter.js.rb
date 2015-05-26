Document.ready? do
  puts "G'day world!" # check the console!
  # Element.find('body > header').html = '<h1>Hi there!</h1>'
  Element.find('#header').on :click do
    alert "The header was clicked!"
  end
end