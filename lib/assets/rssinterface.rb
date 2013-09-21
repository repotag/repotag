require 'net/https'
require 'json'
require 'uri'
require 'rss/2.0'

# RSS Query module to request information of repositories.
# See http://gitblit.com/rpc.html for possible requests.

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

module RSSInterface

  class Client

    def initialize(url, ssl_verify_mode = OpenSSL::SSL::VERIFY_NONE)
      @url = URI.parse(url)
      @http = Net::HTTP.new(@url.host, @url.port)

      if @url.scheme == 'https'
        @http.use_ssl = true
        @http.verify_mode = ssl_verify_mode
      end

    end

    def request(name, params = {}, admin = true)
      @url.query = URI.encode_www_form(params)
      request = Net::HTTP::Get.new("#{@url.path}/#{name}?#{@url.query}")
      request.basic_auth("admin", "admin") if admin
      response = @http.request(request)
      if response.code == "200"
        return RSS::Parser.parse(response.body, false)
      else
        raise "Request failed. Code #{response.code}"
      end
    end

  end
end

# @client = RSSInterface::Client.new('https://localhost:8443/feed')
# rss = @client.request("konijn.git", 'l' => '50', 'h' => 'refs/heads/master')
# puts rss.channel.title
# puts rss.channel.link