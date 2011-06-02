class Location < ActiveRecord::Base
  set_table_name 'mh_location'
  belongs_to :person
  validates_presence_of :person_id, :name, :provider, :location_id, :on => :create, :message => "can't be blank"

  def to_hash
    hash = {}
    hash['name'] = name
    hash['id'] = location_id
    hash['provider'] = provider
    hash
  end

end
