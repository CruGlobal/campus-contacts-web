class AllowSomeFieldsToSaveEmoji < ActiveRecord::Migration
  def change
    execute "ALTER TABLE bulk_messages MODIFY results LONGTEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;"
    #execute "DROP INDEX index_received_sms_on_phone_number_and_message_and_received_at ON received_sms;"
    execute "ALTER TABLE received_sms MODIFY message TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;"
    execute "ALTER TABLE messages MODIFY message TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;"
    execute "ALTER TABLE answers MODIFY value TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;"
    #execute "DROP INDEX index_ma_answers_on_short_value ON answers;"
    execute "ALTER TABLE answers MODIFY short_value TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;"
  end
end
