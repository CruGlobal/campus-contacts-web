class AddQuestionIdToSentSms < ActiveRecord::Migration
  def change
    add_column :sent_sms, :question_id, :integer
  end
end
