class Jobs::UpdateFB
  @queue = :facebook

  def self.perform(person_id,auth,action)
    authentication = auth['authentication']
    person = Person.find_by_id(person_id)
    if person
      case action
      when 'friends'
        if person.friends.count > 0
          person.update_friends(authentication)
        else
          person.get_friends(authentication)
        end
      when 'interests'
        person.get_interests(authentication)
      end
    end
  end
end
