class Ccc::Crs2RegistrantType < ActiveRecord::Base
  set_table_name 'crs2_registrant_type'
  has_many :crs2_additional_expenses_items, :class_name => 'Ccc::Crs2AdditionalExpensesItem'
  has_many :crs2_custom_questions_items, :class_name => 'Ccc::Crs2CustomQuestionsItem'
  has_many :crs2_profile_questions, :class_name => 'Ccc::Crs2ProfileQuestion'
  has_many :crs2_registrants, :class_name => 'Ccc::Crs2Registrant'
  has_many :crs2_registrants, :class_name => 'Ccc::Crs2Registrant'
  belongs_to :crs2_conference, :class_name => 'Ccc::Crs2Conference', :foreign_key => :conference_id
end
