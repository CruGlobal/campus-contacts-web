class Interest < ActiveRecord::Base
  set_table_name 'mh_interests'
  belongs_to :person
  validates_presence_of :person_id, :name, :provider, :interest_id, :category, on: :create, message: "can't be blank"

  def to_hash
    @hash = {}
    @hash['name'] = name
    @hash['id'] = interest_id
    @hash['category'] = category
    @hash['provider'] = provider
    @hash
  end
  
  def self.get_interests_hash(person_id)
    eh = Interest.where("person_id = ?", person_id)
    eh.collect(&:to_hash)
  end
end
