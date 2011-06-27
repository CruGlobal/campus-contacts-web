class Location < ActiveRecord::Base
  set_table_name 'mh_location'
  belongs_to :person
  validates_presence_of :person_id, :name, :provider, :location_id, on: :create, message: "can't be blank"

  def to_hash
    hash = {}
    hash['name'] = name
    hash['id'] = location_id
    hash['provider'] = provider
    hash
  end
  
  # def get_latest_location(person_id)
  #   Location.where("person_id = ?", person_id).order("updated_at DESC").first
  # end  
  # 
  # def self.get_latest_location_hash(person_id)
  #   loc = get_latest_location(person_id)
  #   loc = loc.to_hash if !loc.nil?
  # end
  # 
  # def self.get_locations(person_id)
  #   Location.where("person_id" => person_id).order("updated_at DESC")
  # end
  # 
  # def self.get_locations_hash(person_id)
  #     get_locations(person_id).collect!(&:to_hash)
  # end
end
