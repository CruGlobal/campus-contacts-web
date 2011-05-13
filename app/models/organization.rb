class Organization < ActiveRecord::Base
  has_ancestry
  belongs_to :importable, :polymorphic => true
  validates_presence_of :name
  
  def to_s() name; end
  
  def <=>(other)
    name <=> other.name
  end
end
