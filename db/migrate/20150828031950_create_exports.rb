class CreateExports < ActiveRecord::Migration
  def change
    create_table :exports do |t|
      t.references :person, index: true
      t.references :organization, index: true
      t.string :category
      t.string :kind
      t.text :options
      t.string :status, default: "pending"

      t.timestamps null: false
    end
  end
end
