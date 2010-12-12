class CreateSmsKeywords < ActiveRecord::Migration
  def self.up
    create_table :sms_keywords do |t|
      t.string :keyword
      t.integer :local_level_id
      t.string :name
      t.integer :target_area_id
      t.string :chartfield

      t.timestamps
    end
  end

  def self.down
    drop_table :sms_keywords
  end
end
