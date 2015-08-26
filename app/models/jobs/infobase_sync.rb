require "import_methods"

class Jobs::InfobaseSync
  include Sidekiq::Worker

  def perform
    root = Organization.where(name: "Cru").first_or_create
    Rails.logger.debug "Insert strategies"
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
      "CHS" => "Cru",
      "OT" => "Other"
    }

    chs_ministry = Infobase::Ministry.get("filters[name]" => 'Cru High School')['ministries'].first
    chs = Organization.where(importable_id: chs_ministry['id'], importable_type: 'Ccc::Ministry').first

    ministry_json = Infobase::Ministry.get()['ministries']
    ministry_json.each do |ministry|
      # Import ministry
      Rails.logger.debug "Import Ministry - #{ministry['name']}"
      mh_ministry = Organization.where(importable_id: ministry['id'], importable_type: 'Ccc::Ministry').first
      mh_ministry ||= root.children.create!(name: ministry['name'], terminology: 'Ministry', importable_id: ministry['id'], importable_type: 'Ccc::Ministry')

      # make all regions the second level under the new ministries structure
      regions = {}
      teams = {}
      if ministry['name'] == 'Campus Field Ministry'

        # Import regions
        Rails.logger.debug "-- Importing regions..."
        region_json = Infobase::Region.get()['regions']
        region_json.each do |region|
          Rails.logger.debug "---- Import Region - #{region['name']}"
          attribs = {name: region['name'], terminology: 'Region', importable_id: region['id'], importable_type: 'Ccc::Region'}
          mh_region = Organization.where(importable_id: region['id'], importable_type: 'Ccc::Region').first
          if mh_region
            mh_region.update_attributes(attribs)
          else
            mh_ministry.children.create!(attribs)
          end
          regions[region['abbrv']] = mh_region
        end

        # Import teams
        Rails.logger.debug "-- Importing teams..."
        includes = 'people,phone_numbers,email_addresses'
        team_json = Infobase::Team.get(include: includes)['teams']
        loop do
          team_json.each do |team|
            Rails.logger.debug "---- Import Team - #{team['name']}"
            attribs = {name: team['name'], terminology: 'Missional Team', importable_id: team['id'], importable_type: 'Ccc::MinistryLocallevel', show_sub_orgs: true, status: 'active'}

            mh_team = Organization.where(importable_id: team['id'], importable_type: 'Ccc::MinistryLocallevel').first
            if mh_team
              mh_team.update_attributes(attribs)
            else
              if team['lane'] == 'SV'
                mh_team = chs.children.create!(attribs)
              else
                region = regions[team['region']]
                next unless region
                mh_team = region.children.create!(attribs)
              end
            end

            teams[team['id']] = mh_team
            Rails.logger.debug "------ Importing people..."
            team['people'].each do |ccc_person|
              ImportMethods.person_from_api(ccc_person, mh_team, 'admin')
            end


            Rails.logger.debug "------ Importing activity rows..."
            i = 0
            activity_json = Infobase::Activity.get('filters[team_id]' => team['id'], 'include' => 'target_area', per_page: 10000)['activities']
            activity_json.each do |activity|
              if activity['target_area'].present?
                i += 1
                Rails.logger.debug i if i % 1000 == 0
                mh_activity = Organization.where(importable_id: activity['id'], importable_type: 'Ccc::MinistryActivity').first
                attribs = {name: "#{strategies[activity['strategy']]} at #{activity['target_area']['name']}", terminology: 'Movement', importable_id: activity['id'], importable_type: 'Ccc::MinistryActivity', status: 'active'}
                if mh_activity
                  mh_activity.update_attributes(attribs)

                  if mh_activity.parent_organization != mh_team
                    mh_activity.parent_organization = mh_team
                  end

                  # Ensure that the parents are synchronized
                  mh_activity.fix_ancestry
                else
                  next unless mh_team
                  mh_activity = mh_team.children.create!(attribs)
                  begin
                    mh_activity.save!
                  rescue => e
                    Rails.logger.info e.inspect
                  end
                end
              end
            end
          end

          break unless team_json['meta']['to'] < team_json['meta']['total']
          # get the next page of teams
          team_json = Infobase::Team.get(page: team_json['meta']['page'] + 1, include: includes)
        end
      end
    end
  end
end