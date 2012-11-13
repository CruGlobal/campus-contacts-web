class Friend
  #belongs_to :person
  #validates_presence_of :person_id, :name, :provider, :uid, on: :create, message: "can't be blank"
  attr_accessor :uid, :provider, :name

  def initialize(uid, name = nil, person = nil, provider = 'facebook')
    @uid = uid
    @provider = provider
    @name = name
    follow!(person) if person
  end
  
  def to_hash
    hash = {}
    hash['uid'] = @uid
    hash['name'] = @name
    hash['provider'] = @provider
    hash
  end
  
  def self.get_friends_from_person_id(person_id)
    person = person_id.is_a?(Person) ? person_id : Person.find_by_id(person_id)
    friends = Person.where(fb_uid: Friend.followers(person)).collect { |p| Friend.new(p.fb_uid, p.name) }
  end

  def self.redis_key(obj, str)
    case obj
    when Person
      "friend:#{obj.id}:#{str}" 
    when Friend
      "friend:#{obj.uid}:#{str}"
    else
      "friend:#{obj}:#{str}"
    end
  end

  def self.followers(person)
   $redis.smembers(Friend.redis_key(person, :followers)) || []
  end

  def follow!(person)
    $redis.sadd(Friend.redis_key(self, :following), person.id)
    $redis.sadd(Friend.redis_key(person, :followers), self.uid)
  end

  def following?(person)
    $redis.sismember(Friend.redis_key(self, :following), person.id)
  end

  def unfollow(person)
    Friend.unfollow(person, uid)
  end

  def self.unfollow(person, uid)
    $redis.srem(Friend.redis_key(self, :following), person.id)
    $redis.srem(Friend.redis_key(person, :followers), uid)
  end

  def ==(other)
    other.uid == uid
    other.provider == provider
  end
end
