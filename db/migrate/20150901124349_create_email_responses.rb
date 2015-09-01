class CreateEmailResponses < ActiveRecord::Migration
  def change
    create_table :email_responses do |t|
      t.string :email
      t.text :extra_info
      t.integer :response_type

      t.timestamps null: false
    end
  end
end
