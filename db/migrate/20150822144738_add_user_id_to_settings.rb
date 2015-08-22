class AddUserIdToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :user_id, :integer
  end
end
