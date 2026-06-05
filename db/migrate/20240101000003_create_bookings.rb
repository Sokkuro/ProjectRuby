class CreateBookings < ActiveRecord::Migration[7.0]
  def change
    create_table :bookings do |t|
      t.references :room, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.datetime :start_time, null: false
      t.datetime :end_time, null: false
      t.decimal :total_price, precision: 10, scale: 2, null: false
      t.string :status, null: false, default: "pending"
      t.timestamps
    end

    add_index :bookings, %i[room_id start_time end_time]
  end
end
