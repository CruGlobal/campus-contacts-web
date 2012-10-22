class Ccc::Crs2Registrant < ActiveRecord::Base
  establish_connection :uscm

  self.table_name = 'crs2_registrant'
  has_many :answers, class_name: 'Ccc::Crs2Answer', foreign_key: :registrant_id
  has_many :expense_selections, class_name: 'Ccc::Crs2ExpenseSelection', foreign_key: :registrant_id
  belongs_to :cancelled_by_user, class_name: 'Ccc::Crs2User', foreign_key: :cancelled_by_id
  belongs_to :profile, class_name: 'Ccc::Crs2Profile', foreign_key: :profile_id
  belongs_to :registrant_type, class_name: 'Ccc::Crs2RegistrantType', foreign_key: :registrant_type_id
  belongs_to :registration, class_name: 'Ccc::Crs2Registration', foreign_key: :registration_id
  has_many :transactions, class_name: 'Ccc::Crs2Transaction', foreign_key: :registrant_id
end
