class AddRepositoryIdToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :repository_id, :integer
  end
end
