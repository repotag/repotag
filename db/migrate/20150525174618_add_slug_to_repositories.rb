class AddSlugToRepositories < ActiveRecord::Migration
  def change
    add_column :repositories, :slug, :string
    add_index :repositories, :slug
  end
end
