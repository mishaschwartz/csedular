class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :username, null: false
      t.string :display_name, null: false
      t.string :email, null: true
      t.string :api_key, null: true
      t.boolean :admin, null: false, default: false
      t.boolean :client, null: false, default: false
      t.boolean :read_only, null: false, default: false

      t.timestamps
    end

    add_index :users, :username, unique: true
    add_index :users, :email, unique: true
    add_index :users, :api_key, unique: true
  end
end
