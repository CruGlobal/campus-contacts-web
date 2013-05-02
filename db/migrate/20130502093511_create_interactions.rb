class CreateInteractions < ActiveRecord::Migration
  def change
    create_table :interactions do |t|
      t.integer :interaction_type_id
      t.integer :receiver_id
      t.integer :created_by_id
      t.integer :organization_id
      t.string :comment
      t.string :privacy_setting
      t.datetime :timestamp
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
