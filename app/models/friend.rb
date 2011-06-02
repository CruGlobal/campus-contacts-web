class Friend < ActiveRecord::Base
  set_table_name 'mh_friend'
  belongs_to :person
  validates_presence_of :person_id, :name, :provider, :uid, :on => :create, :message => "can't be blank"
  
  def to_hash
    hash = {}
    hash['uid'] = uid
    hash['name'] = name
    hash['provider'] = provider
    hash
  end
  
  def to_hash_and_slice(valid_fields)
    to_hash.slice(*valid_fields)
  end
  
  def self.get_friends_from_person_id(person_id, valid_fields = nil)
    friends = Friend.where("person_id = ?",person_id)
    if valid_fields.nil?
      friends = friends.collect(&:to_hash)
    else friends = friends.collect {|x| x.to_hash_and_slice(valid_fields)}
    end
    friends
  end
end
