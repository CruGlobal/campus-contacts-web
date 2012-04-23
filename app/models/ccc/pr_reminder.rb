class Ccc::PrReminder < ActiveRecord::Base
  self.table_name = "pr_reminders"
  validates_presence_of :label
  belongs_to :person

  def self.send_all_emails
    Reminder.where(:send_email => true, :email_sent_at => nil).each do |reminder|
      if reminder.reminder_date - Date.today <= reminder.email_days_diff
        InvitesMailer.manual_reminder(reminder, "Reminder Email").deliver
        reminder.email_sent_at = Date.today
        reminder.save!
      end
    end
  end
end
