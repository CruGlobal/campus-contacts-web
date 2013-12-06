class ChangeInteractionPrivacy < ActiveRecord::Migration
  def up
    say "Converting the privacy setting all interactions from 'everyone' or 'parents' to 'organization'."
    execute "UPDATE interactions SET privacy_setting = 'organization' WHERE privacy_setting = 'everyone' OR privacy_setting = 'parents';"
  end

  def down
  end
end
