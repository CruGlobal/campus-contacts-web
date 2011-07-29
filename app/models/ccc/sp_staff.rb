class Ccc::SpStaff < ActiveRecord::Base
  set_table_name 'sp_staff'
  belongs_to :ministry_person, class_name: 'Person', foreign_key: :person_id
  belongs_to :sp_projects, class_name: 'Ccc::SpProject', foreign_key: :project_id


end 
