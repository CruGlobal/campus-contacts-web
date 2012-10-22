class Ccc::SiApply < ActiveRecord::Base
  establish_connection :uscm

	# belongs_to :person
  has_one :application, class_name: 'Ccc::HrSiApplication', foreign_key: :apply_id, dependent: :destroy
  has_many :apply_sheets, class_name: 'Ccc::SiApplySheet', foreign_key: :apply_id, dependent: :destroy
  has_many :answer_sheets, through: :apply_sheets, dependent: :destroy
  belongs_to :person, foreign_key: :applicant_id
end
