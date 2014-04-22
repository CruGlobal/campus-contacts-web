namespace :sp do
  require "import_methods"

  desc "pulls the ministry_* table info into missionhub tables"

  def import_ministry(ministry_hash, parent_org)
    org = Organization.where(importable_id: ministry_hash['id'], importable_type: 'Ccc::Ministry').first
    org ||= parent_org.children.create!(name: ministry_hash['name'], terminology: 'Ministry', importable_id: ministry_hash['id'], importable_type: 'Ccc::Ministry')
    return org
  end

  def import_mission(year, parent_org)
    org = parent_org.children.where(name: ["Summer Mission #{year}","Summer Missions #{year}"], terminology: 'Mission').first
    org.update_attribute(:name, "Summer Missions #{year}") if org.name == "Summer Mission #{year}"
    org ||= parent_org.children.create!(name: "Summer Missions #{year}", terminology: 'Mission')
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

    ImportMethods.person_from_api(project_hash['pd'], org, 'admin') if project_hash['pd'].present?
    ImportMethods.person_from_api(project_hash['apd'], org, 'admin') if project_hash['apd'].present?
    ImportMethods.person_from_api(project_hash['opd'], org, 'admin') if project_hash['opd'].present?
    ImportMethods.person_from_api(project_hash['coordinator'], org, 'admin') if project_hash['coordinator'].present?

    project_hash['staff'].each do |person|
      ImportMethods.person_from_api(person, org, 'user')
    end if project_hash['staff'].present?

    project_hash['volunteers'].each do |person|
      ImportMethods.person_from_api(person, org, 'user')
    end if project_hash['volunteers'].present?

    project_hash['applicants'].each do |person|
      ImportMethods.person_from_api(person, org, 'contact')
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
    region_json = Infobase::Region.get()['regions']
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