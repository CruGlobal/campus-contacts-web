class AddPlatformReleaseAndPlatformProductToApiLog < ActiveRecord::Migration
  def change
    add_column :api_logs, :platform_release, :string
    add_column :api_logs, :platform_product, :string
    add_column :api_logs, :app, :string
  end
end
