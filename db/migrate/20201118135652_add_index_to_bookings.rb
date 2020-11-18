class AddIndexToBookings < ActiveRecord::Migration[6.0]
  def change
    add_index :bookings, [:availability_id, :user_id], unique: true
  end
end
