class CreateRejoicables < ActiveRecord::Migration
  def change
    create_table :rejoicables do |t|
      t.integer :person_id
      t.integer :created_by_id
      t.integer :organization_id
      t.integer :followup_comment_id
      t.column :what, "ENUM('#{Rejoicable::OPTIONS.join("','")}')"

      t.timestamps
    end
  end
end
