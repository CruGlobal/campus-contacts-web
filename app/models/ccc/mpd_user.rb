class Ccc::MpdUser < ActiveRecord::Base
	self.table_name = 'mpd_users'
	has_many :mpd_contacts, class_name: 'Ccc::MpdContact', dependent: :destroy
	has_many :mpd_events, class_name: 'Ccc::MpdEvent', dependent: :destroy
	has_many :mpd_expenses, class_name: 'Ccc::MpdExpense', dependent: :destroy
	has_many :mpd_priorities, class_name: 'Ccc::MpdPriority', dependent: :destroy
	has_many :mpd_letters, class_name: 'Ccc::MpdLetter', dependent: :destroy


  def merge(other)
		other.mpd_contacts.each { |ua| ua.update_attribute(:mpd_user_id, id) }
		other.mpd_events.each { |ua| ua.update_attribute(:mpd_user_id, id) }
		other.mpd_expenses.each { |ua| ua.update_attribute(:mpd_user_id, id) }
		other.mpd_priorities.each { |ua| ua.update_attribute(:mpd_user_id, id) }
		other.mpd_letters.each { |ua| ua.update_attribute(:mpd_user_id, id) }
  end
  
end
