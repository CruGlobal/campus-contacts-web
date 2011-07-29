class Ccc::SnTimetable < ActiveRecord::Base
  belongs_to :ministry_person, class_name: 'Person', foreign_key: :person_id

end
