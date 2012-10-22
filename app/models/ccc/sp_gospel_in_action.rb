class Ccc::SpGospelInAction < ActiveRecord::Base
  establish_connection :uscm

  has_many :sp_project_gospel_in_actions, class_name: 'Ccc::SpProjectGospelInAction'
end
