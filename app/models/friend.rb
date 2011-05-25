class Friend < ActiveRecord::Base
  set_table_name 'mh_friend'
  belongs_to :person
  validates_presence_of :person_id, :name, :provider, :uid, :on => :create, :message => "can't be blank"
  
  def to_custom
    { :uid => self.uid, :name => self.name, :provider => self.provider}
  end
  
end
