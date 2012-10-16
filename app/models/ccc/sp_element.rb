class Ccc::SpElement < ActiveRecord::Base
  establish_connection :uscm

  has_many :sp_page_elements, class_name: 'Ccc::SpPageElement'
  has_many :sp_references, class_name: 'Ccc::SpReference'
end
