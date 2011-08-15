namespace :infobase do
  desc "pulls the ministry_* table info into missionhub tables"
  task sync: :environment do
    root = Organization.find_or_create_by_name "Campus Crusade for Christ"
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
      "SV" => "Student Venture",
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
    Organization.connection.select_all("select * from ministry_regionalteam where region <> ''").each do |region|
      attribs = {name: region['name'], terminology: 'Region', importable_id: region['teamID'], importable_type: 'Ccc::Region'}
      r = Organization.where(importable_id: region['teamID'], importable_type: 'Ccc::Region').first
      r ? r.update_attributes(attribs) : campus.children.create!(attribs)
      regions[region['region']] = r
    end

    team_id_to_ministry = {}
    puts "Done regions.  Insert local level."

    # ministry local level goes next
    Organization.connection.select_all("select * from ministry_locallevel").each do |level|
      m = Organization.where(importable_id: level['teamID'], importable_type: 'Ccc::MinistryLocallevel').first
      attribs = {name: level['name'], terminology: 'Missional Team', importable_id: level['teamID'], importable_type: 'Ccc::MinistryLocallevel'}
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
    Organization.connection.select_all("select * from ministry_missional_team_member").each do |mtm|
      # personID, teamID
      team = team_id_to_ministry[mtm['teamID']]
      next unless team
      team.add_admin(mtm['personID'])
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
        attribs = {name: "#{strategies[activity.strategy]} at #{target.name}", terminology: 'Movement', importable_id: activity.id, importable_type: 'Ccc::MinistryActivity'}
        if m
          m.update_attributes(attribs)
        else
          team = Organization.where(importable_id: activity.fk_teamID, importable_type: 'Ccc::MinistryLocallevel').first
          next unless team
          m = team.children.create!(attribs) 
          m.target_areas << target
          m.save!
        end
      end
      
      # Find all the students active in the system in the past year, and add them to this movement
      # Person.where(["dateChanged > ? AND (isStaff is null OR isStaff = 0) AND campus = ?", 1.year.ago, target.name]).each do |person|
      #   unless OrganizationMembership.where(organization_id: m.id, person_id: person.id).present?
      #     OrganizationMembership.create!(organization_id: m.id, person_id: person.id, validated: 1, start_date: person.dateCreated)
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
