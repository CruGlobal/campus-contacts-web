class Ccc::SiUser < ActiveRecord::Base
  establish_connection :uscm

	# belongs_to :user
  def self.inheritance_column
    'fdsagh3208hsaf'
  end
end
