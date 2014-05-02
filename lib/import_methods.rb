module ImportMethods
  def self.person_from_api(person_hash, org, type = 'contact')
    unless person_hash['user_id'].present?
      puts "-------- Import Person - #{type} - #{person_hash['first_name']} #{person_hash['last_name']} - Failed! ~ user_id not present in summer project db"
      return nil
    end

    begin
      ccc_user = SummerProject::User.find(person_hash['user_id'], include: 'authentications')['user']
    rescue
      puts "-------- Import Person - #{type} - #{person_hash['first_name']} #{person_hash['last_name']} - Failed! ~ user_id not found in summer project db"
      return nil
    end

    # If this person doesn't already exist in missionhub, we need to create them
    # We'll try to match on FB authentication, then username

    unless mh_person = Person.where(infobase_person_id: person_hash['id']).first
      ccc_authentication = ccc_user['authentications'].detect {|a| a['provider'] == 'facebook'}
      authentication = Authentication.where(ccc_authentication.slice('provider', 'uid')).first if ccc_authentication
      if authentication && authentication.user
        mh_person = authentication.user.person
      else
        user = User.find_by_username(ccc_user['username'])
        mh_person = user.person if user
      end
    end

    # If we didn't find a corresponding person in MH, create one
    unless mh_person
      person = SummerProject::Person.get('filters[id]' => person_hash['id'], include: 'current_address,email_addresses,phone_numbers')['people'].first
      unless person.present?
        puts "-------- Import Person - #{type} - #{person_hash['first_name']} #{person_hash['last_name']} - Failed! ~ person not found in summper project db"
        return nil
      end

      attributes = person.except('id', 'created_at', 'dateChanged', 'fk_ssmUserId', 'fk_StaffSiteProfileID', 'fk_spouseID', 'fk_childOf', 'primary_campus_involvement_id', 'mentor_id')
      attributes['first_name'] = attributes['preferred_name'].present? ? attributes['preferred_name'] : attributes['first_name']

      attributes['graduation_date'] = nil unless Person.valid_attribute?(:graduation_date, attributes['graduation_date'])
      attributes['birth_date'] = nil unless Person.valid_attribute?(:birth_date, attributes['birth_date'])
      attributes['infobase_person_id'] = person['id']

      mh_person_attributes = Person.first.attributes.keys
      attributes.slice!(*mh_person_attributes)

      mh_person = Person.create(attributes)
      mh_person.user = user ||
                       User.find_by_username(ccc_user['username']) ||
                       User.create(username: ccc_user['username'], password: Devise.friendly_token[0,20])

      # copy over email and phone data
      person['email_addresses'].each do |email_address|
        mh_person.email = email_address['email'] unless mh_person.email_addresses.detect {|e| email_address['email'] == e.email} || EmailAddress.where(email: email_address['email']).first
      end

      mh_person.save!

      person['phone_numbers'].each do |phone|
        mh_person.phone_number = phone['number'] unless mh_person.phone_numbers.detect {|p| p.number == phone['number']}
      end
    end

    mh_person.sp_person_id = mh_person.si_person_id = mh_person.pr_person_id = mh_person.infobase_person_id = person_hash['id']
    mh_person.save(validate: false) if mh_person.changed?

    case type
    when 'admin'
      org.add_admin(mh_person)
    when 'user'
      org.add_user(mh_person)
    else
      org.add_contact(mh_person)
    end
    puts "-------- Import Person - #{type} - #{person_hash['first_name']} #{person_hash['last_name']} - Success!"
    return mh_person
  end
end
