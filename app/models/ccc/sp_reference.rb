class Ccc::SpReference < ActiveRecord::Base
  belongs_to :sp_elements, class_name: 'Ccc::SpElement', foreign_key: :question_id
end
