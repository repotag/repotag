require 'net/https'
require 'json'
require 'uri'

# Monkey-patch to add method :encode_www_form(enum) to URI in 1.8 mode.
if RUBY_VERSION == "1.8.7"
  module URI
    def self.encode_www_form(enum)
      str = nil
      enum.each do |k,v|
        if str
          str << '&'
        else
          str = nil.to_s
        end
        str << encode_www_form_component(k)
        str << '='
        str << encode_www_form_component(v)
      end
      str
    end
  end
end

# JsonRPC module to communicate with git servlet.
# See http://gitblit.com/rpc.html for possible requests.

module JsonRPC

  class Client

    def initialize(url, ssl_verify_mode = OpenSSL::SSL::VERIFY_NONE)
      @url = URI.parse(url)
      @http = Net::HTTP.new(@url.host, @url.port)

      if @url.scheme == 'https'
        @http.use_ssl = true
        @http.verify_mode = ssl_verify_mode
      end

    end

    # The body param is an ActiveRecord model such as Repository or User.
    def request(params, body = {}, admin = true)
      @url.query = URI.encode_www_form(params)
      request = Net::HTTP::Post.new("#{@url.path}?#{@url.query}")
      request["Content-Type"] = 'application/json'
      request.body = ActiveSupport::JSON.encode(body)
      request.basic_auth("admin", "admin") if admin
      response = @http.request(request)
      if response.code == "200"
        begin
          return JSON.parse(response.body)
        rescue => e
          return true
        end
        else
        raise "Request failed. Code #{response.code}"
      end
    end

  end
end