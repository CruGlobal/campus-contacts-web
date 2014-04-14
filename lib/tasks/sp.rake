namespace :sp do
  desc "pulls the ministry_* table info into missionhub tables"

  def import_ministry(ministry_hash, parent_org)
    org = Organization.where(importable_id: ministry_hash['id'], importable_type: 'Ccc::Ministry').first
    org ||= parent_org.children.create!(name: ministry_hash['name'], terminology: 'Ministry', importable_id: ministry_hash['id'], importable_type: 'Ccc::Ministry')
    return org
  end

  def import_mission(year, parent_org)
    org = parent_org.children.where(name: "Summer Mission #{year}", terminology: 'Mission').first
    org ||= parent_org.children.create!(name: "Summer Mission #{year}", terminology: 'Mission')
    return org
  end

  def import_region(region_hash, parent_org)
    org = Organization.where(importable_id: region_hash['id'], importable_type: 'Ccc::Region').first
    org ||= parent_org.children.create!(name: region_hash['name'], terminology: 'Region', importable_id: region_hash['id'], importable_type: 'Ccc::Region')
    return org
  end

  def import_team(team_hash, parent_org)
    org = Organization.where(importable_id: team_hash['id'], importable_type: 'Ccc::MinistryLocallevel').first
    org ||= parent_org.children.create!(name: team_hash['name'], terminology: 'Missional Team', importable_id: team_hash['id'], importable_type: 'Ccc::MinistryLocallevel')
    return org
  end

  def import_project(project_hash, parent_org)
    org = Organization.where(importable_id: project_hash['id'], importable_type: 'Ccc::SpProject').first
    org ||= parent_org.children.create!(name: project_hash['name'], terminology: 'Project', importable_id: project_hash['id'], importable_type: 'Ccc::SpProject')

    import_person(project_hash['pd'], org, 'admin') if project_hash['pd'].present?
    import_person(project_hash['apd'], org, 'admin') if project_hash['apd'].present?
    import_person(project_hash['opd'], org, 'admin') if project_hash['opd'].present?

    project_hash['staff'].each do |person|
      import_person(person, org, 'user')
    end if project_hash['staff'].present?

    project_hash['volunteers'].each do |person|
      import_person(person, org, 'user')
    end if project_hash['volunteers'].present?

    project_hash['applicants'].each do |person|
      import_person(person, org, 'contact')
    end if project_hash['applicants'].present?

    return org
  end

  def get_search_name(ministry)
    case ministry['name']
    when 'Athletes In Action'
      return "AIA"
    when 'Global Missions'
      return "WSN"
    else
      ministry['name']
    end
  end

  def import_person(person_hash, org, type = 'contact')
    puts "-------- Import Person - #{type} - #{person_hash['first_name']} #{person_hash['last_name']}"
    return nil unless person_hash['user_id'].present?
    begin
      ccc_user = SummerProject::User.find(person_hash['user_id'], include: 'authentications')['user']
    rescue
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
      return nil unless person.present?

      attributes = person.except('id', 'created_at', 'dateChanged', 'fk_ssmUserId', 'fk_StaffSiteProfileID', 'fk_spouseID', 'fk_childOf', 'primary_campus_involvement_id', 'mentor_id')
      attributes['first_name'] = attributes['preferred_name'].present? ? attributes['preferred_name'] : attributes['first_name']

      attributes['graduation_date'] = nil unless Person.valid_attribute?(:graduation_date, attributes['graduation_date'])
      attributes['birth_date'] = nil unless Person.valid_attribute?(:birth_date, attributes['birth_date'])
      attributes['infobase_person_id'] = person['id']

      mh_person_attributes = Person.first.attributes.keys
      attributes.slice!(*mh_person_attributes)

      mh_person = Person.create!(attributes)
      mh_person.user = user ||
                       User.find_by_username(ccc_user['username']) ||
                       User.create!(username: ccc_user['username'], password: Time.now.to_i)

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
  end

  def get_projects(primary_partner, year, is_not = false)
    project_includes = "pd,apd,opd,staff,volunteers,applicants"
    filter = is_not ? 'not_primary_partner' : 'primary_partner'
    return SummerProject::Project.get("filters[#{filter}]" => primary_partner, "filters[year]" => year, include: project_includes, per_page: 100000)['projects']
  end

  # Main Task
  task sync: :environment do
    imported_partner = Array.new
    root = Organization.find_or_create_by_name "Cru"

    # Fetch Ministries (Cru High School, Bridges, Athletes In Action) ***Bridges is temporarily removed
    ministry_json = Infobase::Ministry.get('filters[names]' => 'Cru High School, Athletes In Action')['ministries']
    ministry_json.each do |ministry|
      puts "-- Checking Ministry - #{ministry['name']}"
      mh_ministry = import_ministry(ministry, root)

      # Import Non-CRU ministries
      (2014..Date.today.year).each do |year|
        puts "---- Importing Projects #{year}..."
        search_name = get_search_name(ministry)
        project_json = get_projects(search_name, year)
        if project_json.present?
          mh_mission = import_mission(year, mh_ministry)
          project_json.each do |project|
            puts "------ Checking Project - #{year} - #{project['name']}"
            imported_partner << project['primary_partner']
            mh_project = import_project(project, mh_mission)
          end
        end
      end
    end

    # Fetch Regions and Teams for Campus Field Ministry
    ministry = Infobase::Ministry.get('filters[names]' => 'Campus Field Ministry')['ministries'].first
    mh_ministry = import_ministry(ministry, root)
    puts "-- Checking Ministry - #{ministry['name']}"
    puts "---- Importing Regions..."
    region_json = SummerProject::Region.get()['regions']
    region_json.each do |region|
      puts "------ Checking Region - #{region['abbrv']} - #{region['name']}"
      mh_region = import_region(region, mh_ministry)
      (2014..Date.today.year).each do |year|
        puts "-------- Importing Projects #{year}..."
        project_json = get_projects(region['abbrv'], year)
        if project_json.present?
          mh_mission = import_mission(year, mh_region)
          project_json.each do |project|
            puts "---------- Checking Project - #{year} - #{project['name']}"
            imported_partner << project['primary_partner']
            mh_project = import_project(project, mh_mission)
          end
        end
      end

      # puts "---- Importing Team..."
      # team_json = Infobase::Team.get('filters[lanes]' => 'SC,CA', 'filters[country]' => 'USA')['teams']
      # team_json.each do |team|
      #   puts "------ Checking Team - #{team['lane']} - #{team['name']}"
      #   mh_team = import_team(team, mh_region)
      #   (2014..Date.today.year).each do |year|
      #     puts "-------- Importing Projects #{year}..."
      #     project_json = get_projects(team['name'], year)
      #     if project_json.present?
      #       mh_mission = import_mission(year, mh_region)
      #       project_json.each do |project|
      #         puts "---------- Checking Project - #{year} - #{project['name']}"
      #         imported_partner << project['primary_partner']
      #         mh_project = import_project(project, mh_mission)
      #       end
      #     end
      #   end
      # end
    end

    # Fetch Non-SP Projects
    non_sp = root.children.where(name: "Other Summer Projects", terminology: 'Other Summer Projects').first
    non_sp ||= root.children.create!(name: "Other Summer Projects", terminology: 'Other Summer Projects')
    imported_partner << "Bridges" # skip bridges
    puts "-- Checking Other Summer Projects - #{ministry['name']}"
    (2014..Date.today.year).each do |year|
      puts "---- Importing Other Summer Projects #{year}..."
      puts "---- Not #{imported_partner.uniq}"
      project_json = get_projects(imported_partner.uniq.join(','), year, true)
      if project_json.present?
        mh_mission = import_mission(year, non_sp)
        project_json.each do |project|
          puts "------ Checking Project - #{year} - #{project['name']}"
          mh_project = import_project(project, mh_mission)
        end
      end
    end

  end
end