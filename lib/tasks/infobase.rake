namespace :infobase do
  desc "pulls the ministry_* table info into sn_* tables"
  task :sync => :environment do
    root = Organization.find_or_create_by_name "Campus Crusade for Christ"
    puts "Insert strategies"
    # First set up the strategies
    strategies = {
      "FS" => "Campus Ministry",
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
    campus = nil
    strategies.each_pair do |ab, name|
      if strategy = Ccc::Strategy.find_by_name(name)
        unless s = Organization.where(:importable_id => strategy.id, :importable_type => 'Ccc::Strategy').first
          s = root.children.create!(:name => name, :terminology => 'Strategy', :importable_id => strategy.id, :importable_type => 'Ccc::Strategy')
        end
        campus = s if ab == 'FS'
      end
    end

    puts "Done strategies.  Insert regions."

    # make all regions the second level under the new ministries structure
    regions = {}
    Organization.connection.select_all("select * from ministry_regionalteam where region <> ''").each do |region|
      attribs = {:name => region['name'], :terminology => 'Region', :importable_id => region['teamID'], :importable_type => 'Ccc::Region'}
      r = Organization.where(:importable_id => region['teamID'], :importable_type => 'Ccc::Region').first
      r ? r.update_attributes(attribs) : campus.children.create!(attribs)
      regions[region['region']] = r
    end

    team_id_to_ministry_id = {}
    puts "Done regions.  Insert local level."

    # ministry local level goes next
    Organization.connection.select_all("select * from ministry_locallevel").each do |level|
      m = Organization.where(:importable_id => level['teamID'], :importable_type => 'Ccc::LocalLevel').first
      attribs = {:name => level['name'], :terminology => 'Missional Team', :importable_id => level['teamID'], :importable_type => 'Ccc::LocalLevel'}
      if m
        m.update_attributes(attribs)
      else
        region = regions[level['region']]
        next unless region
        m = region.children.create!(attribs) 
      end

      team_id_to_ministry_id[level['teamID']] = m.id
    end

    puts "Done local level."

    # next is activity
    #strategy_abbrev_to_name = Hash[Strategy.all.collect{ |s| [ s.abbrv, s.name ] } ]
    #strategy_abbrev_to_id = Hash[Strategy.all.collect{ |s| [ s.abbrv, s.id ] } ]
    #campus_id_to_name = Hash[Campus.all(:select => "targetAreaID, name").collect{ |c| [ c.targetAreaID.to_s, c.name ] }]
    
    #activity_id_to_ministry_id = {}
    # puts "Need to go through activity rows"
    # i = 0
    # Organization.connection.select_all("select * from ministry_locallevel").each do |activity|
    #   #name = "#{strategy_abbrev_to_name[activity.strategy]} - #{campus_id_to_name[activity.fk_targetAreaID]}"
    #   #m = Organization.find_or_create_by_name name
    #   #m.parent_id = team_id_to_ministry_id[activity.fk_teamID]
    #   #m.status = activity.status
    #   #m.strategy_id = strategy_abbrev_to_id[activity.strategy]
    #   #m.legacy_activity_id = activity.ActivityID
    #   #m.save(false)
    # 
    #   #activity_id_to_ministry_id[activity.ActivityID.to_s] = m.id.to_s
    # 
    #   i += 1
    #   puts i if i % 1000 == 0
    # 
    #   # TODO: also need to add ministry campus
    #   begin
    #     OrganizationCampus.create! :ministry_id => team_id_to_ministry_id[activity.fk_teamID], :campus_id => activity.fk_targetAreaID
    #   rescue
    #   end
    # end
    # 
    # #Organization.connection.execute("UPDATE organizations SET type = 'activity' WHERE legacy_activity_id IS NOT NULL")
    # 
    puts "Copy ministry_missional_team_member"
    
    #OrganizationMembership.set_table_name "sn_ministry_involvements2"
    #OrganizationMembership.reset_column_information 
    mtms = OrganizationMembership.find_by_sql("select * from ministry_missional_team_member")
    # team_member_role_id = Organization.find(1).ministry_roles.find_by_name("Missional Team Member").id
    # team_leader_role_id = Organization.find(1).ministry_roles.find_by_name("Missional Team Leader").id
    puts "Adding team members"
    i = 0
    Organization.connection.select_all("select * from ministry_missional_team_member").each do |mtm|
      # personID, teamID
      team = team_id_to_ministry_id[mtm['teamID']]
      next unless team
      #debugger
      unless OrganizationMembership.where(:organization_id => team, :person_id => mtm['personID']).present?
        OrganizationMembership.create!(:organization_id => team, :person_id => mtm['personID'], :validated => 1)
      end
      i += 1
      puts i if i % 1000 == 0
    end
    # 
    # # update groups without semester set to the current semester
    # Group.update_all({ :semester_id => Semester.current }, { :semester_id => nil })
  end

end
