class CreateCruStatuses < ActiveRecord::Migration
  def change
    create_table :cru_statuses do |t|
      t.integer :organization_id, default: 0
      t.string :name
      t.string :i18n

      t.timestamps
    end
  end
end
