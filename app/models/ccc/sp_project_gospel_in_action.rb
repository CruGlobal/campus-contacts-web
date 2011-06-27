class Ccc::SpProjectGospelInAction < ActiveRecord::Base
  belongs_to :sp_gospel_in_actions, class_name: 'Ccc::SpGospelInAction', foreign_key: :gospel_in_action_id
  belongs_to :sp_projects, class_name: 'Ccc::SpProject', foreign_key: :project_id
end
