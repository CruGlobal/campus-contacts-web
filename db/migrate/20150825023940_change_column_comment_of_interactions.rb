class ChangeColumnCommentOfInteractions < ActiveRecord::Migration
  def change
    execute "ALTER TABLE interactions MODIFY comment TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;"
  end
end
