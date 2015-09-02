class RestoreTableColumnsUtf8Encoding < ActiveRecord::Migration
  def change
    execute "ALTER TABLE bulk_messages MODIFY results LONGTEXT CHARACTER SET utf8 COLLATE utf8_general_ci;"
    execute "ALTER TABLE received_sms MODIFY message TEXT CHARACTER SET utf8 COLLATE utf8_general_ci;"
    execute "ALTER TABLE messages MODIFY message TEXT CHARACTER SET utf8 COLLATE utf8_general_ci;"
    execute "ALTER TABLE answers MODIFY value TEXT CHARACTER SET utf8 COLLATE utf8_general_ci;"
    execute "ALTER TABLE answers MODIFY short_value TEXT CHARACTER SET utf8 COLLATE utf8_general_ci;"
    execute "ALTER TABLE sent_sms MODIFY message TEXT CHARACTER SET utf8 COLLATE utf8_general_ci;"
    execute "ALTER TABLE interactions MODIFY comment TEXT CHARACTER SET utf8 COLLATE utf8_general_ci;"
  end
end
