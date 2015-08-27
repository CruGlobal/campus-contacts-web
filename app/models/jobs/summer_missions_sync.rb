require "import_methods"

class Jobs::SummerMissionsSync
  include Sidekiq::Worker
  include Retryable
  sidekiq_options unique: true

  def perform
    imported_partner = Array.new
    root = Organization.where(name: "Cru").first_or_create

    # Fetch Ministries (Cru High School, Bridges, Athletes In Action) ***Bridges is temporarily removed
    ministry_json = Infobase::Ministry.get('filters[names]' => 'Cru High School, Athletes In Action')['ministries']
    ministry_json.each do |ministry|
      Rails.logger.debug "-- Checking Ministry - #{ministry['name']}"
      mh_ministry = import_ministry(ministry, root)

      # Import Non-CRU ministries
      (2014..Date.today.year).each do |year|
        Rails.logger.debug "---- Importing Projects #{year}..."
        search_name = get_search_name(ministry)

        page = 1
        begin
          api_response = get_projects(search_name, year, false, page)
          meta = api_response['meta']
          page = meta['page']
          last_record = meta['to']
          total_record = meta['total']
          Rails.logger.debug "------ #{meta.inspect}"

          project_json = api_response['projects']
          if project_json.present?
            mh_mission = import_mission(year, mh_ministry)
            project_json.each do |project|
              Rails.logger.debug "------ Checking Project - #{year} - #{project['name']}"
              imported_partner << project['primary_partner']
              mh_project = import_project(project, mh_mission)
            end
          end
          page += 1
        end while last_record < total_record

      end
    end

    # Fetch Regions and Teams for Campus Field Ministry
    ministry = Infobase::Ministry.get('filters[names]' => 'Campus Field Ministry')['ministries'].first
    begin
      mh_ministry = import_ministry(ministry, root)
    rescue
      raise "Cannot import ministry: #{ministry.inspect}"
    end
    Rails.logger.debug "-- Checking Ministry - #{ministry['name']}"
    Rails.logger.debug "---- Importing Regions..."
    region_json = Infobase::Region.get()['regions']
    region_json.each do |region|
      Rails.logger.debug "------ Checking Region - #{region['abbrv']} - #{region['name']}"
      mh_region = import_region(region, mh_ministry)
      (2014..Date.today.year).each do |year|
        Rails.logger.debug "-------- Importing Projects #{year}..."

        page = 1
        begin
          api_response = get_projects(region['abbrv'], year, false, page)
          meta = api_response['meta']
          page = meta['page']
          last_record = meta['to']
          total_record = meta['total']
          Rails.logger.debug "------ #{meta.inspect}"

          project_json = api_response['projects']
          if project_json.present?
            mh_mission = import_mission(year, mh_region)
            project_json.each do |project|
              Rails.logger.debug "---------- Checking Project - #{year} - #{project['name']}"
              imported_partner << project['primary_partner']
              mh_project = import_project(project, mh_mission)
            end
          end
          page += 1
        end while last_record < total_record

      end

      # Rails.logger.debug "---- Importing Team..."
      # team_json = Infobase::Team.get('filters[lanes]' => 'SC,CA', 'filters[country]' => 'USA')['teams']
      # team_json.each do |team|
      #   Rails.logger.debug "------ Checking Team - #{team['lane']} - #{team['name']}"
      #   mh_team = import_team(team, mh_region)
      #   (2014..Date.today.year).each do |year|
      #     Rails.logger.debug "-------- Importing Projects #{year}..."
      #     project_json = get_projects(team['name'], year)
      #     if project_json.present?
      #       mh_mission = import_mission(year, mh_region)
      #       project_json.each do |project|
      #         Rails.logger.debug "---------- Checking Project - #{year} - #{project['name']}"
      #         imported_partner << project['primary_partner']
      #         mh_project = import_project(project, mh_mission)
      #       end
      #     end
      #   end
      # end
    end

    # Fetch Non-SP Projects
    non_sp = root.children.where(name: "Other Summer Projects", terminology: 'Other Summer Projects').first
    non_sp ||= root.children.where(name: "Other Summer Projects", terminology: 'Other Summer Projects').first_or_create
    imported_partner << "Bridges" # skip bridges
    Rails.logger.debug "-- Checking Other Summer Projects - #{ministry['name']}"
    (2014..Date.today.year).each do |year|
      Rails.logger.debug "---- Importing Other Summer Projects #{year}..."
      Rails.logger.debug "---- Not #{imported_partner.uniq}"

      page = 1
      begin
        api_response = get_projects(imported_partner.uniq.join(','), year, true, page)
        meta = api_response['meta']
        page = meta['page']
        last_record = meta['to']
        total_record = meta['total']
        Rails.logger.debug "------ #{meta.inspect}"

        project_json = api_response['projects']
        if project_json.present?
          mh_mission = import_mission(year, non_sp)
          project_json.each do |project|
            Rails.logger.debug "------ Checking Project - #{year} - #{project['name']}"
            mh_project = import_project(project, mh_mission)
          end
        end
        page += 1
      end while last_record < total_record

    end
  end

  def import_ministry(ministry_hash, parent_org)
    org = Organization.where(importable_id: ministry_hash['id'], importable_type: 'Ccc::Ministry').first
    org ||= parent_org.children.where(name: ministry_hash['name'], terminology: 'Ministry', importable_id: ministry_hash['id'], importable_type: 'Ccc::Ministry').first_or_create
    return org
  end

  def import_mission(year, parent_org)
    org = parent_org.children.where(name: ["Summer Mission #{year}","Summer Missions #{year}"], terminology: 'Mission').first
    org.update_attribute(:name, "Summer Missions #{year}") if org.present? && org.name == "Summer Mission #{year}"
    org ||= parent_org.children.where(name: "Summer Missions #{year}", terminology: 'Mission').first_or_create
    return org
  end

  def import_region(region_hash, parent_org)
    org = Organization.where(importable_id: region_hash['id'], importable_type: 'Ccc::Region').first
    org ||= parent_org.children.where(name: region_hash['name'], terminology: 'Region', importable_id: region_hash['id'], importable_type: 'Ccc::Region').first_or_create
    return org
  end

  def import_team(team_hash, parent_org)
    org = Organization.where(importable_id: team_hash['id'], importable_type: 'Ccc::MinistryLocallevel').first
    org ||= parent_org.children.where(name: team_hash['name'], terminology: 'Missional Team', importable_id: team_hash['id'], importable_type: 'Ccc::MinistryLocallevel').first_or_create
    return org
  end

  def import_project(project_hash, parent_org)
    org = Organization.where(importable_id: project_hash['id'], importable_type: 'Ccc::SpProject').first
    org ||= parent_org.children.where(name: project_hash['name'], terminology: 'Project', importable_id: project_hash['id'], importable_type: 'Ccc::SpProject').first_or_create

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

  def get_projects(primary_partner, year, is_not = false, page = 1)
    project_includes = "pd,apd,opd,staff,volunteers,applicants"
    filter = is_not ? 'not_primary_partner' : 'primary_partner'
    retryable do
      return SummerProject::Project.get("filters[#{filter}]" => primary_partner, "filters[year]" => year, include: project_includes, per_page: 3, page: page)
    end
  end
end