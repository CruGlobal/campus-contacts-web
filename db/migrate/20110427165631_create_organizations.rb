class CreateOrganizations < ActiveRecord::Migration
  def self.up
    create_table :organizations do |t|
      t.string :name
      t.boolean :requires_validation, :default => false
      t.string :validation_method

      t.timestamps
    end
  end

  def self.down
    drop_table :organizations
  end
end
