class Ccc::SpReference < ActiveRecord::Base
  establish_connection :uscm

  belongs_to :sp_elements, class_name: 'Ccc::SpElement', foreign_key: :question_id
end
