class Ccc::SpProject < ActiveRecord::Base
	#belongs_to :person
  has_many :sp_applications, class_name: 'Ccc::SpApplication'
  has_many :sp_project_gospel_in_actions, class_name: 'Ccc::SpProjectGospelInAction'
  has_many :sp_staffs, class_name: 'Ccc::SpStaff'
  has_many :sp_student_quotes, class_name: 'Ccc::SpStudentQuote'

  def merge(other)
    # change old pd_id to new pd_id (all personID)
    # change old apd_id to new apd_id
    # change old opd_id to new opd_id
    # change old coordinator_id to new coordinator_id 
  end

  def to_s
    name
  end

end
