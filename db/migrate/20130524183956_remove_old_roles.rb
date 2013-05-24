class Role < ActiveRecord::Base
end
class RemoveOldRoles < ActiveRecord::Migration
  def up
    Role.where("i18n NOT IN (?)", ['admin', 'contact', 'missionhub_user', 'archived']).delete_all
  end

  def down
  end
end
