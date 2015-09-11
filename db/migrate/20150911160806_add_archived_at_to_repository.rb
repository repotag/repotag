class AddArchivedAtToRepository < ActiveRecord::Migration
  def change
    add_column :repositories, :archived_at, :datetime
  end
end
