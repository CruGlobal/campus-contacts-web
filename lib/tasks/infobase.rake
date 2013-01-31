namespace :infobase do
  desc "pulls the ministry_* table info into missionhub tables"
  task sync: :environment do
    root = Organization.find_or_create_by_name "Cru"
    puts "Insert strategies"
    # First set up the strategies
    strategies = {
      "FS" => "Cru",
      "IE" => "Epic",
      "ID" => "Destino",
      "II" => "Impact",
      "IN" => "Nations",
      "WS" => "WSN",
      "BR" => "Bridges",
      "AA" => "Athletes In Action",
      "FC" => "Faculty Commons",
      "KC" => "Korean CCC",
      "GK" => "Greek",
      "VL" => "Valor",
      "SV" => "Cru",
      "OT" => "Other"
    }
    campus_ministry = Ccc::Ministry.find_or_create_by_name('Campus Ministry')
    campus = Organization.where(importable_id: campus_ministry.id, importable_type: 'Ccc::Ministry').first
    campus ||= root.children.create!(name: campus_ministry.name, terminology: 'Ministry', importable_id: campus_ministry.id, importable_type: 'Ccc::Ministry')
    # strategies.each_pair do |ab, name|
    #   if strategy = Ccc::Strategy.find_by_name(name)
    #     unless s = Organization.where(importable_id: strategy.id, importable_type: 'Ccc::Strategy').first
    #       s = root.children.create!(name: name, terminology: 'Strategy', importable_id: strategy.id, importable_type: 'Ccc::Strategy')
    #     end
    #     campus = s if ab == 'FS'
    #   end
    # end

    puts "Insert regions."

    # make all regions the second level under the new ministries structure
    regions = {}
    Ccc::Person.connection.select_all("select * from ministry_regionalteam where region <> ''").each do |region|
      attribs = {name: region['name'], terminology: 'Region', importable_id: region['teamID'], importable_type: 'Ccc::Region'}
      r = Organization.where(importable_id: region['teamID'], importable_type: 'Ccc::Region').first
      r ? r.update_attributes(attribs) : campus.children.create!(attribs)
      regions[region['region']] = r
    end

    team_id_to_ministry = {}
    puts "Done regions.  Insert local level."

    # ministry local level goes next
    Ccc::Person.connection.select_all("select * from ministry_locallevel where isActive = 'T'").each do |level|
      m = Organization.where(importable_id: level['teamID'], importable_type: 'Ccc::MinistryLocallevel').first
      attribs = {name: level['name'], terminology: 'Missional Team', importable_id: level['teamID'], importable_type: 'Ccc::MinistryLocallevel', show_sub_orgs: true, status: 'active'}
      if m
        m.update_attributes(attribs)
      else
        region = regions[level['region']]
        next unless region
        m = region.children.create!(attribs)
      end

      team_id_to_ministry[level['teamID']] = m
    end

    puts "Done local level."

    puts "Copy ministry_missional_team_member"

    #OrganizationMembership.set_table_name "sn_ministry_involvements2"
    #OrganizationMembership.reset_column_information
    # mtms = OrganizationMembership.find_by_sql("select * from ministry_missional_team_member")
    # team_member_role_id = Organization.find(1).ministry_roles.find_by_name("Missional Team Member").id
    # team_leader_role_id = Organization.find(1).ministry_roles.find_by_name("Missional Team Leader").id
    puts "Adding team members"
    i = 0
    Ccc::Person.connection.select_all("select * from ministry_missional_team_member").each do |mtm|
      # personID, teamID
      team = team_id_to_ministry[mtm['teamID']]
      next unless team

      # If this person doesn't already exist in missionhub, we need to create them
      # We'll try to match on FB authentication, then username
      ccc_person = Ccc::Person.find(mtm['personID'])
      next unless ccc_person.user

      ccc_authentication = ccc_person.user.authentications.where(provider: 'facebook').first
      authentication = Authentication.where(ccc_authentication.attributes.slice('provider', 'uid')).first if ccc_authentication
      if authentication && authentication.user
        mh_person = authentication.user.person
      else
        user = User.find_by_username(ccc_person.user.username)
        mh_person = user.person if user
      end

      # If we didn't find a corresponding person in MH, create one
      unless mh_person
        attributes = ccc_person.attributes.except('personID', 'created_at', 'dateChanged', 'fk_ssmUserId', 'fk_StaffSiteProfileID', 'fk_spouseID', 'fk_childOf', 'primary_campus_involvement_id', 'mentor_id')
        attributes['first_name'] = attributes['preferredName'].present? ? attributes['preferredName'] : attributes['firstName']
        attributes['last_name'] = attributes.delete('lastName')
        attributes['middle_name'] = attributes.delete('middleName')

        mh_person_attributes = Person.first.attributes.keys
        attributes.slice!(*mh_person_attributes)

        mh_person = Person.create!(attributes)
        mh_person.user = user ||
                         User.find_by_username(ccc_person.user.username) ||
                         User.create!(username: ccc_person.user.username, password: Time.now.to_i)

        # copy over email and phone data
        ccc_person.email_addresses.each do |email_address|
          mh_person.email = email_address.email unless mh_person.email_addresses.detect {|e| email_address.email == e.email} || EmailAddress.where(email: email_address.email).first
        end
        mh_person.save!
        
        ccc_person.phone_numbers.each do |phone|
          mh_person.phone_number = phone.number unless mh_person.phone_numbers.detect {|p| p.number == phone.number}
        end
        mh_person.save!(validate: false)
      end

      team.add_admin(mh_person)

      i += 1
      puts i if i % 1000 == 0
    end

    # next is activity
    puts "Import activities as movements"
    #strategy_abbrev_to_name = Hash[Strategy.all.collect{ |s| [ s.abbrv, s.name ] } ]
    #strategy_abbrev_to_id = Hash[Strategy.all.collect{ |s| [ s.abbrv, s.id ] } ]
    campus_id_to_name = Hash[Ccc::MinistryTargetarea.all(select: "targetAreaID, name").collect{ |c| [ c.targetAreaID.to_s, c.name ] }]

    puts "Need to go through activity rows"
    i = 0
    Ccc::MinistryActivity.where("status NOT IN('IN', 'TN')").each do |activity|
      if activity.fk_targetAreaID.present?
        i += 1
        puts i if i % 1000 == 0
        target = TargetArea.find(activity.fk_targetAreaID)
        m = Organization.where(importable_id: activity.id, importable_type: 'Ccc::MinistryActivity').first
        attribs = {name: "#{strategies[activity.strategy]} at #{target.name}", terminology: 'Movement', importable_id: activity.id, importable_type: 'Ccc::MinistryActivity', status: 'active'}
        team = Organization.where(importable_id: activity.fk_teamID, importable_type: 'Ccc::MinistryLocallevel').first
        if m
          if team == m.parent
            m.update_attributes(attribs)
          else
            # The movement was moved from one team to another
            m.parent = team
            m.save!
          end
        else
          next unless team
          m = team.children.create!(attribs)
          m.target_areas << target
          begin
            m.save!
          rescue => e
            Rails.logger.info e.inspect
          end
        end
      end

      # Find all the students active in the system in the past year, and add them to this movement
      # Person.where(["dateChanged > ? AND (isStaff is null OR isStaff = 0) AND campus = ?", 1.year.ago, target.name]).each do |person|
      #   unless OrganizationMembership.where(organization_id: m.id, person_id: person.id).present?
      #     OrganizationMembership.create!(organization_id: m.id, person_id: person.id, validated: 1, start_date: person.created_at)
      #   end
      # end

    end

    # Inactivate inactive activities
    # Ccc::MinistryActivity.where("status IN('IN', 'TN')").each do |activity|
    #   m = Organization.where(importable_id: activity.id, importable_type: 'Ccc::MinistryActivity').first
    #   m.destroy if m
    # end
  end

end
