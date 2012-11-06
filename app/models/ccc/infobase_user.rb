class Ccc::InfobaseUser < ActiveRecord::Base
  establish_connection :uscm

  TYPES = %w[InfobaseUser InfobaseHrUser InfobaseAdminUser]
  belongs_to :user

  def merge(other)
    # If the other user is a higher rank, delete this user
		if TYPES.index(other.type) > TYPES.index(type)
		  self.destroy
		  other.update_attributes!(user_id: user_id)
		  other
	  else
	    other.destroy
	    self
    end
  end
  
end
