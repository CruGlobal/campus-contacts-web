class Ccc::SpPageElement < ActiveRecord::Base
  establish_connection :uscm

  belongs_to :sp_pages, class_name: 'Ccc::SpPage', foreign_key: :page_id
  belongs_to :sp_elements, class_name: 'Ccc::SpElement', foreign_key: :element_id
end
