class CreateRooms < ActiveRecord::Migration[7.0]
  def change
    create_table :rooms do |t|
      t.string :name, null: false
      t.string :location, null: false
      t.decimal :price_per_hour, precision: 10, scale: 2, null: false
      t.references :user, null: false, foreign_key: true
      t.boolean :is_active, null: false, default: true
      t.timestamps
    end
  end
end
