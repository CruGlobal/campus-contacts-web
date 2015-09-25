class ChangeEncodingOfObjectsFromVersions < ActiveRecord::Migration
  def change
    execute("ALTER TABLE versions MODIFY `object` text CHARACTER SET utf8 COLLATE utf8_bin;")
  end
end
