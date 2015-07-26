class AddDescriptionToRepositories < ActiveRecord::Migration
  def change
    add_column :repositories, :description, :string
  end
end
