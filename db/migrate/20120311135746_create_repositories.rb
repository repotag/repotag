class CreateRepositories < ActiveRecord::Migration
  def change
    create_table :repositories do |t|
      t.string :name,   :default => ""
      t.timestamps
    end
  end
end
