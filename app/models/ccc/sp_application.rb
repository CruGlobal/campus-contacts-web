class Ccc::SpApplication < ActiveRecord::Base
  belongs_to :person, class_name: 'SpProject', foreign_key: :person_id
  belongs_to :sp_project, class_name: 'Ccc::SpProject', foreign_key: :project_id

end
