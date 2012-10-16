class Ccc::MinistryNote < ActiveRecord::Base
  establish_connection :uscm

  self.primary_key = 'NoteID'
  self.table_name = 'ministry_note'
  
end
