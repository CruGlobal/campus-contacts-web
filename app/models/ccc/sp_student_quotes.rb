class Ccc::SpStudentQuote < ActiveRecord::Base
  belongs_to :sp_projects, :class_name => 'Ccc::SpProject', :foreign_key => :project_id
end
