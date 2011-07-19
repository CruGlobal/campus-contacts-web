class Jobs::UpdateFB
  @queue = :facebook
  
  def self.perform(person_id,auth,action)
    authentication = auth['authentication']
    person = Person.find_by_personID(person_id)
    if person
      case action
      when 'friends'
        if person.friends.count > 0
          last_updated_friend = person.friends.order("`#{Friend.table_name}`.`updated_at` DESC").first
          if last_updated_friend.updated_at < 1.day.ago 
            person.update_friends(authentication)
          end
        else 
          person.get_friends(authentication)
        end
      when 'interests'
        person.get_interests(authentication)
      end
    end
  end
end