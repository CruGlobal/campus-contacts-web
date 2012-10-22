class Ccc::Crs2Transaction < ActiveRecord::Base
  establish_connection :uscm

  self.table_name = 'crs2_transaction'
  set_inheritance_column 'fake'
  belongs_to :crs2_transaction, class_name: 'Ccc::Crs2Transaction', foreign_key: :charge_cancellation_id
  belongs_to :crs2_conference, class_name: 'Ccc::Crs2Conference', foreign_key: :conference_id
  belongs_to :crs2_expense_selection, class_name: 'Ccc::Crs2ExpenseSelection', foreign_key: :expense_selection_id
  belongs_to :crs2_transaction, class_name: 'Ccc::Crs2Transaction', foreign_key: :paid_by_id
  belongs_to :crs2_transaction, class_name: 'Ccc::Crs2Transaction', foreign_key: :payment_cancellation_id
  belongs_to :crs2_registrant, class_name: 'Ccc::Crs2Registrant', foreign_key: :registrant_id
  belongs_to :crs2_registration, class_name: 'Ccc::Crs2Registration', foreign_key: :registration_id
  belongs_to :crs2_transaction, class_name: 'Ccc::Crs2Transaction', foreign_key: :scholarship_charge_id
  belongs_to :crs2_user, class_name: 'Ccc::Crs2User', foreign_key: :user_id
  belongs_to :crs2_user, class_name: 'Ccc::Crs2User', foreign_key: :verified_by_id

end
