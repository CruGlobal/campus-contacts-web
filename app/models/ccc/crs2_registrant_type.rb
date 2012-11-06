class Ccc::Crs2RegistrantType < ActiveRecord::Base
  establish_connection :uscm

  self.table_name = 'crs2_registrant_type'
  has_many :additional_expenses_items, class_name: 'Ccc::Crs2AdditionalExpensesItem', foreign_key: :registrant_type_id
  has_many :custom_questions_items, class_name: 'Ccc::Crs2CustomQuestionsItem', foreign_key: :registrant_type_id
  has_many :profile_questions, class_name: 'Ccc::Crs2ProfileQuestion', foreign_key: :registrant_type_id
  has_many :registrants, class_name: 'Ccc::Crs2Registrant', foreign_key: :registrant_type_id
  belongs_to :conference, class_name: 'Ccc::Crs2Conference', foreign_key: :conference_id
end
