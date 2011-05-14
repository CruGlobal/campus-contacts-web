class Ccc::SpProject < ActiveRecord::Base
  has_many :sp_applications, :class_name => 'Ccc::SpApplication'
  has_many :sp_project_gospel_in_actions, :class_name => 'Ccc::SpProjectGospelInAction'
  has_many :sp_staffs, :class_name => 'Ccc::SpStaff'
  has_many :sp_student_quotes, :class_name => 'Ccc::SpStudentQuote'
end
