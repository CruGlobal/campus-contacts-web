class CreateLongCodes < ActiveRecord::Migration
  def change
    create_table :long_codes do |t|
      t.string :number
      t.integer :messages_sent, default: 0
      t.boolean :active, default: true, null: false

      t.timestamps
    end
  end
end
