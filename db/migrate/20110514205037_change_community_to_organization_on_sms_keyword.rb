class ChangeCommunityToOrganizationOnSmsKeyword < ActiveRecord::Migration
  def change
    rename_column :sms_keywords, :community_id, :organization_id
    rename_column :sms_keywords, :activity_id, :event_id
    add_column :sms_keywords, :event_type, :string
  end
end