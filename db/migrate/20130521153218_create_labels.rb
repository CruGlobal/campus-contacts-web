class CreateLabels < ActiveRecord::Migration
  def up
    create_table :labels do |t|
      t.integer :organization_id
      t.string :name
      t.string :i18n

      t.timestamps
    end
  end

  def down
    drop_table :labels
  end
end
