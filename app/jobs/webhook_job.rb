class WebhookJob < ActiveJob::Base
  require 'ostruct'
  queue_as :default

  def perform(repo)
    ActiveRecord::Base.connection_pool.with_connection do
      # Find all webhooks for repo
      # webhooks = Webhook.where(repository_id: repo.id)
      # For demo purposes:
      webhooks = [OpenStruct.new(url: "http://httpbin.org/post", body: {data_example: 'data'})]

      webhooks.each do |webhook|
        result = HTTParty.post(webhook.url, 
            :body => webhook.body.to_json,
            :headers => { 'Content-Type' => 'application/json' } )
        $stderr.puts "result: #{result.inspect}"    
      end
    
    end
  end
end