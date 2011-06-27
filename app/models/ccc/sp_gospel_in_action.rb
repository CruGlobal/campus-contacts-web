class Ccc::SpGospelInAction < ActiveRecord::Base
  has_many :sp_project_gospel_in_actions, class_name: 'Ccc::SpProjectGospelInAction'
end
