class CreateResources < ActiveRecord::Migration[6.0]
  def change
    create_table :resources do |t|
      t.string :resource_type, null: false
      t.string :name, null: false
      t.references :location, foreign_key: true, null: false

      t.timestamps
    end

    add_index :resources, [:location_id, :name], unique: true
  end
end
