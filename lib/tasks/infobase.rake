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
    ['Campus Ministry','AIA'].each do |ministry_name|
      campus_ministry = Infobase::Ministry.get("filters[name]" => ministry_name)['ministries'].first
      campus = Organization.where(importable_id: campus_ministry['id'], importable_type: 'Ccc::Ministry').first
      campus ||= root.children.create!(name: campus_ministry['name'], terminology: 'Ministry', importable_id: campus_ministry['id'], importable_type: 'Ccc::Ministry')
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
      Infobase::Region.get['regions'].each do |region|
        attribs = {name: region['name'], terminology: 'Region', importable_id: region['id'], importable_type: 'Ccc::Region'}
        r = Organization.where(importable_id: region['id'], importable_type: 'Ccc::Region').first
        r ? r.update_attributes(attribs) : campus.children.create!(attribs)
        regions[region['abbrv']] = r
      end

      team_id_to_ministry = {}
      puts "Done regions.  Insert local level teams."

      includes = 'people,phone_numbers,email_addresses'
      team_json = Infobase::Team.get(include: includes)
      while team_json['meta']['to'] < team_json['meta']['total'] do
        team_json['teams'].each do |team|
          mh_team = Organization.where(importable_id: team['id'], importable_type: 'Ccc::MinistryLocallevel').first
          attribs = {name: team['name'], terminology: 'Missional Team', importable_id: team['id'], importable_type: 'Ccc::MinistryLocallevel',
                     show_sub_orgs: true, status: 'active'}
          if mh_team
            mh_team.update_attributes(attribs)
          else
            region = regions[team['region']]
            next unless region
            mh_team = region.children.create!(attribs)
          end

          team_id_to_ministry[team['id']] = mh_team

          puts "Adding team members for #{team['name']}"
          i = 0

          team['people'].each do |ccc_person|

            next unless ccc_person['user_id'].present?
            ccc_user = Infobase::User.find(ccc_person['user_id'], include: 'authentications')['user']

            # If this person doesn't already exist in missionhub, we need to create them
            # We'll try to match on FB authentication, then username

            unless mh_person = Person.where(infobase_person_id: ccc_person['id']).first
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
              attributes = ccc_person.except('id', 'created_at', 'dateChanged', 'fk_ssmUserId', 'fk_StaffSiteProfileID', 'fk_spouseID', 'fk_childOf', 'primary_campus_involvement_id', 'mentor_id')
              attributes['first_name'] = attributes['preferred_name'].present? ? attributes['preferred_name'] : attributes['first_name']
              attributes['infobase_person_id'] = ccc_person['id']

              mh_person_attributes = Person.first.attributes.keys
              attributes.slice!(*mh_person_attributes)

              mh_person = Person.create!(attributes)
              mh_person.user = user ||
                               User.find_by_username(ccc_user['username']) ||
                               User.create!(username: ccc_user['username'], password: Time.now.to_i)

              # copy over email and phone data
              ccc_person['email_addresses'].each do |email_address|
                mh_person.email = email_address['email'] unless mh_person.email_addresses.detect {|e| email_address['email'] == e.email} || EmailAddress.where(email: email_address['email']).first
              end


              mh_person.save!

              ccc_person['phone_numbers'].each do |phone|
                mh_person.phone_number = phone['number'] unless mh_person.phone_numbers.detect {|p| p.number == phone['number']}
              end
            end

            mh_person.sp_person_id = mh_person.si_person_id = mh_person.pr_person_id = mh_person.infobase_person_id = ccc_person['id']
            mh_person.save(validate: false) if mh_person.changed?

            mh_team.add_admin(mh_person)

            i += 1
            puts i if i % 1000 == 0
          end


          puts "Need to go through activity rows"
          i = 0
          Infobase::Activity.get('filters[team_id]' => team['id'], per_page: 10000)['activities'].each do |activity|
            if activity['target_area'].present?
              i += 1
              puts i if i % 1000 == 0
              mh_activity = Organization.where(importable_id: activity['id'], importable_type: 'Ccc::MinistryActivity').first
              attribs = {name: "#{strategies[activity['strategy']]} at #{activity['target_area']['name']}", terminology: 'Movement', importable_id: activity['id'], importable_type: 'Ccc::MinistryActivity', status: 'active'}
              if mh_activity
                if mh_team == mh_activity.parent
                  mh_activity.update_attributes(attribs)
                else
                  begin
                    # The movement was moved from one team to another
                    mh_activity.parent = mh_team
                    mh_activity.save!
                  rescue; end
                end
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

          # get the next page of teams
          team_json = Infobase::Team.get(page: team_json['meta']['page'] + 1, include: includes)
        end
      end
    end
  end

end
