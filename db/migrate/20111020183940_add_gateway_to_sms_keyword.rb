class AddGatewayToSmsKeyword < ActiveRecord::Migration
  def change
    add_column :sms_keywords, :gateway, :string, :null => false, :default => ''
  end
end
