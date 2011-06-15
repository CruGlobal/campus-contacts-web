class CreateFollowupComments < ActiveRecord::Migration
  def up
    create_table :followup_comments do |t|
      t.integer :contact_id
      t.integer :commenter_id
      t.text :comment
      t.string :status
      t.integer :organization_id
    
      t.timestamps
    end
    add_index :followup_comments, [:organization_id, :contact_id], :name => 'comment_organization_id_contact_id'
  end
  
  def down
    drop_table :followup_comments
  end
end