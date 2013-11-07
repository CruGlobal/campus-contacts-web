require 'open-uri'
class Ccc::PhoneNumber < ActiveRecord::Base
  establish_connection :uscm

  belongs_to :person, class_name: 'Ccc::Person'

end