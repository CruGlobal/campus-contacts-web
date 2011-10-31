class AddDeletedAtToFollowupComments < ActiveRecord::Migration
  def change
    add_column :followup_comments, :deleted_at, :datetime
  end
end
