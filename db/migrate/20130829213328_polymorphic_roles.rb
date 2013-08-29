class PolymorphicRoles < ActiveRecord::Migration
  def up
    remove_column :roles, :repository_id
    remove_column :users, :admin
    add_column :roles, :resource_id, :integer
    add_column :roles, :resource_type, :string
  end

  def down
    remove_column :roles, :resource_id
    add_column :users, :admin, :boolean, :default => false
    add_column :roles, :repository_id, :integer
  end
end
