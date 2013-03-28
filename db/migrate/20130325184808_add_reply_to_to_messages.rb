class AddReplyToToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :reply_to, :string, after: "to"
  end
end
