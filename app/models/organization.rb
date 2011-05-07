class Organization < ActiveRecord::Base
  has_ancestry
  validates_presence_of :name
  default_scope :order => 'name'
  
  def to_s() name; end
end
