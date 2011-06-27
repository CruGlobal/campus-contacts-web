class Ccc::SpQuestionSheet < ActiveRecord::Base
  has_many :sp_pages, class_name: 'Ccc::SpPage'
end
