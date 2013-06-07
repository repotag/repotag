class AddPublicToRepository < ActiveRecord::Migration
  def change
    add_column :repositories, :public, :boolean, :default => false
  end
end
