class AddArchivedToRepository < ActiveRecord::Migration
  def change
    add_column :repositories, :archived, :boolean, default: false
  end
end
