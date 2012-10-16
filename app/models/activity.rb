class Activity < ActiveRecord::Base
  establish_connection :uscm

  belongs_to :target_area
  belongs_to :organization

  before_validation :set_start_date, on: :create
  
  protected
  
  def set_start_date
    self.start_date = Date.today
  end
end
