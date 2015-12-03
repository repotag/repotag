class RepositoryCleanupJob < ActiveJob::Base
  queue_as :default

  # Example task. May be called with 
  #  RepositoryCleanupJob.perform_later(1.day.ago.to_s)
  def perform(older_than)
    ActiveRecord::Base.connection_pool.with_connection do
      repos = Repository.where("updated_at < :older_than", older_than: older_than )
      puts "Logging from RepositoryCleanupJob."
      puts "These repos might be ready to be archived: #{repos.inspect}"
    end

  end
end
