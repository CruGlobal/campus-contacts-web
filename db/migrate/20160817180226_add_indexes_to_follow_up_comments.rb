class AddIndexesToFollowUpComments < ActiveRecord::Migration
  def change
    add_index :followup_comments, [:deleted_at, :contact_id]
  end
end
