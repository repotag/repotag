class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.string :settings
      t.string :name

      t.timestamps
    end
  end
end
