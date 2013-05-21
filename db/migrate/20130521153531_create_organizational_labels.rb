class CreateOrganizationalLabels < ActiveRecord::Migration
  def change
    create_table :organizational_labels do |t|
      t.integer :person_id
      t.integer :label_id
      t.integer :organization_id
      t.date :start_date
      t.integer :added_by_id
      t.date :removed_date

      t.timestamps
    end
  end
end
