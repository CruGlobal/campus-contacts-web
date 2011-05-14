class Ccc::FskFieldsRole < ActiveRecord::Base
  belongs_to :fsk_fields, :class_name => 'Ccc::FskField', :foreign_key => :field_id
  belongs_to :fsk_roles, :class_name => 'Ccc::FskRole', :foreign_key => :role_id
end
