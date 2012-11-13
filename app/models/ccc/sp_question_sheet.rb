class Ccc::SpQuestionSheet < ActiveRecord::Base
  establish_connection :uscm

  has_many :sp_pages, class_name: 'Ccc::SpPage'
end
