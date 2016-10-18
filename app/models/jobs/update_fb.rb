class Jobs::UpdateFB
  include Sidekiq::Worker
  sidekiq_options unique: true

  def perform(person_id, auth, _action)
    return false unless auth.present?
    authentication = auth['authentication']
    person = Person.find_by_id(person_id)
    if person && authentication
      if person.friends.count > 0
        person.update_friends(authentication)
      else
        person.get_friends(authentication)
      end
    end
  end
end
