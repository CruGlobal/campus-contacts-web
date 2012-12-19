class CreateSentRole < ActiveRecord::Migration
  def up
    execute("INSERT INTO `roles` (`organization_id`, `name`, `i18n`, `created_at`, `updated_at`) VALUES (0, '100% Sent', 'sent', '2012-11-28 15:31:36', '2012-11-28 15:31:36');")
  end

  def down
  end
end
