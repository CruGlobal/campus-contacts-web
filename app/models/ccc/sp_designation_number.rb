class Ccc::SpDesignationNumber < ActiveRecord::Base
  establish_connection :uscm

  belongs_to :person
end
