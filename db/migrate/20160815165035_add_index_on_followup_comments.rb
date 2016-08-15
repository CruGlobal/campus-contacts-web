class AddIndexOnFollowupComments < ActiveRecord::Migration
  def change
    add_index :followup_comments, :commenter_id
  end
end
