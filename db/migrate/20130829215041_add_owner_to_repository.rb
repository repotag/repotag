class AddOwnerToRepository < ActiveRecord::Migration
  def change
    add_column :repositories, :owner_id, :integer
  end
end
