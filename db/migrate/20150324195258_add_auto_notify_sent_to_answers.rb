class AddAutoNotifySentToAnswers < ActiveRecord::Migration
  def change
    add_column :answers, :auto_notify_sent, :boolean, after: "short_value", default: false
    Answer.update_all(auto_notify_sent: true)
  end
end
