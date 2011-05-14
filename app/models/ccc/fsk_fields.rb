class Ccc::FskField < ActiveRecord::Base
  has_many :fsk_fields_roles, :class_name => 'Ccc::FskFieldsRole'
end
