class Friend < ActiveRecord::Base
  set_table_name 'mh_friends'
  belongs_to :person
  validates_presence_of :person_id, :name, :provider, :uid, on: :create, message: "can't be blank"
  
  def to_hash
    hash = {}
    hash['uid'] = uid
    hash['name'] = name
    hash['provider'] = provider
    hash
  end
  
  def self.get_friends_from_person_id(person_id, valid_fields = nil)
    friends = Friend.where("person_id = ?",person_id)
    if valid_fields.nil?
      friends = friends.collect(&:to_hash)
    else friends = friends.collect {|x| x.to_hash.slice(*valid_fields)}
    end
    person = Person.find_by_personID(person_id)
    hash = { person: {name: person.to_s, id: person.id }, friends: friends }
  end
end
