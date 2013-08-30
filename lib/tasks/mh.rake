require 'resque/tasks'
task "resque:setup" => :environment do
end

task "answer_comments" => :environment do
  OrganizationalRole.contact.includes(:organization, {person: :answer_sheets}).each do |role|
    OrganizationalRole.transaction do
      next unless role.person && role.person.answer_sheets.present?
      organization = role.organization
      questions = organization.all_questions
      FollowupComment.create_from_survey(organization, role.person, organization.all_questions, role.person.answer_sheets, 'uncontacted', role.created_at)
    end
  end
end

task "carriers" => :environment do
  # require 'hpricot'
  require 'open-uri'
  PhoneNumber.connection.select_values("select distinct(number) as number from phone_numbers where txt_to_email is null or txt_to_email = '' order by updated_at desc").each do |number|
    puts number
    next unless number.length == 10
    url = "https://api.data24-7.com/textat.php?username=support@missionhub.com&password=Windows7&p1=#{number}"
    xml = Nokogiri::XML(open(url, :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE))
    begin
      email = xml.xpath('.//sms_address').text
      carrier_name = xml.xpath('.//carrier_name').text
      carrier = SmsCarrier.find_or_create_by_data247_name(carrier_name)
      PhoneNumber.connection.update("update phone_numbers set carrier_id = #{carrier.id}, txt_to_email = '#{email}', email_updated_at = '#{Time.now.to_s(:db)}' where number = '#{number}'")
    rescue => e
      raise xml.inspect + "\n" + e.inspect
    end
    # time_to_sleep = rand(5) + 2
    # puts "Sleeping #{time_to_sleep} seconds"
    # sleep(time_to_sleep)
  end
end



task "phone_numbers" => :environment do
  # Copy phone numbers from ministry_newaddress to phone_numbers table
  sql = "select homePhone, cellPhone, workPhone, person_id from ministry_newaddress a where a.address_type = 'current'"
  ActiveRecord::Base.connection.select_all(sql).each do |row|
    person = Person.find_by_id(row['person_id'])
    if person
      {'homePhone' => 'home', 'cellPhone' => 'mobile', 'workPhone' => 'work'}.each do |column, location|
        num = row[column]
        stripped_num = num.to_s.gsub(/[^\d]/, '')
        if stripped_num.length == 10
          person.phone_numbers.find_by_number(stripped_num) || person.phone_numbers.create(number: stripped_num, location: location)
        end
      end
    end
  end
end

task "move_answers" => :environment do
  bad_id = ENV['bad_id']
  good_id = ENV['good_id']
  bad = Element.find(bad_id)
  good = Element.find(good_id)
  # Copy answers over
  bad.sheet_answers.each do |a|
    Element.transaction do
      begin
        good.set_response(a.value, a.answer_sheet)
      rescue ActiveRecord::RecordNotUnique
      end
    end
  end

  # For every survey the bad question was on, add the good question and remove the bad
  bad.surveys.each do |survey|
    survey.elements = survey.elements + [good] - [bad]
    survey.save
  end

  bad.destroy
end

task 'restore_org' => :environment do
  def q(s)
    return 'NULL' unless s
    case
    when s.is_a?(String)
      "'#{Mysql2::Client.escape(s)}'"
    else
      s
    end
  end

  old_id = ENV['old_id']
  new_id = ENV['new_id']

  Organization.transaction do
    Organization.connection.update("update labels set organization_id = #{new_id} where organization_id = #{old_id}")

    #labels = Label.connection.select_all("select id, #{new_id} as organization_id, name, i18n, created_at, updated_at from missionhub_20130829.labels where organization_id = #{old_id}")
    #labels.each do |ol|
      #sql = "insert into labels(id, organization_id, name, i18n, created_at, updated_at) VALUES (#{ol['id']}, #{ol['organization_id']}, #{q(ol['name'])}, '#{q(ol['i18n'])}', '#{ol['created_at']}', '#{ol['updated_at']}')"
      #puts sql
      #Organization.connection.insert(sql)
    #end

    Organization.connection.update("update organizational_labels set organization_id = #{new_id} where organization_id = #{old_id}")

    #organizational_labels = Organization.connection.select_all("select id, person_id, label_id, #{new_id} as organization_id, start_date, added_by_id, removed_date, created_at, updated_at from missionhub_20130829.organizational_labels where organization_id = #{old_id}")
    #organizational_labels.each do |ol|
      #sql = "insert into organizational_labels(id, person_id, label_id, organization_id, start_date, added_by_id, removed_date, created_at, updated_at) VALUES (#{ol['id']}, #{ol['person_id']}, #{ol['label_id']}, #{ol['organization_id']}, '#{ol['start_date']}', #{ol['added_by_id']}, '#{ol['removed_date']}', '#{ol['created_at']}', '#{ol['updated_at']}')"
      #puts sql
      #Organization.connection.insert(sql)
    #end

    Organization.connection.update("update contact_assignments set organization_id = #{new_id} where organization_id = #{old_id}")

    #contact_assignments = Label.connection.select_all("select id, #{new_id} as organization_id, assigned_to_id, person_id, created_at, updated_at from missionhub_20130829.contact_assignments where organization_id = #{old_id}")
    #contact_assignments.each do |ol|
      #if ol['person_id'].present? && ol['assigned_to_id'].present?
        #sql = "insert into contact_assignments(id, organization_id, assigned_to_id, person_id, created_at, updated_at) VALUES (#{ol['id']}, #{ol['organization_id']}, #{ol['assigned_to_id']}, #{ol['person_id']}, '#{ol['created_at']}', '#{ol['updated_at']}')"
        #puts sql
        #Organization.connection.insert(sql)
      #end
    #end

    Organization.connection.update("update followup_comments set organization_id = #{new_id} where organization_id = #{old_id}")

    #followup_comments = Label.connection.select_all("select id, #{new_id} as organization_id, contact_id, commenter_id, comment, status, deleted_at, created_at, updated_at from missionhub_20130829.followup_comments where organization_id = #{old_id}")
    #followup_comments.each do |ol|
      #sql = "insert into followup_comments(id, organization_id, contact_id, commenter_id, comment, status, deleted_at, created_at, updated_at) VALUES (#{ol['id']}, #{ol['organization_id']}, #{ol['contact_id']}, #{ol['commenter_id']}, #{q(ol['comment'])}, #{q(ol['status'])}, #{q(ol['deleted_at'])}, '#{ol['created_at']}', '#{ol['updated_at']}')"
      #puts sql
      #Organization.connection.insert(sql)
    #end

    Organization.connection.update("update groups set organization_id = #{new_id} where organization_id = #{old_id}")

    #groups = Label.connection.select_all("select id, #{new_id} as organization_id, name, location, meets, meeting_day, start_time, end_time, list_publicly, approve_join_requests, created_at, updated_at from missionhub_20130829.groups where organization_id = #{old_id}")
    #groups.each do |ol|
      #sql = "insert into groups(id, organization_id, name, location, meets, meeting_day, start_time, end_time, list_publicly, approve_join_requests, created_at, updated_at) VALUES (#{ol['id']}, #{ol['organization_id']}, #{q(ol['name'])}, #{q(ol['location'])}, #{q(ol['meets'])}, #{ol['meeting_day']}, #{ol['start_time']}, #{ol['end_time']}, #{ol['list_publicly']}, #{ol['approve_join_requests']}, '#{ol['created_at']}', '#{ol['updated_at']}')"
      #puts sql
      #Organization.connection.insert(sql)
    #end

    Organization.connection.update("update group_labels set organization_id = #{new_id} where organization_id = #{old_id}")

    #group_labels = Label.connection.select_all("select id, #{new_id} as organization_id, name, ancestry, group_labelings_count, created_at, updated_at from missionhub_20130829.group_labels where organization_id = #{old_id}")
    #group_labels.each do |ol|
      #sql = "insert into group_labels(id, organization_id, name, ancestry, group_labelings_count, created_at, updated_at) VALUES (#{ol['id']}, #{ol['organization_id']}, #{q(ol['name'])}, #{ol['ancestry']}, #{ol['group_labelings_count']}, '#{ol['created_at']}', '#{ol['updated_at']}')"
      #puts sql
      #Organization.connection.insert(sql)
    #end

    #groups.each do |group|
      #group_memberships = Label.connection.select_all("select id, group_id, person_id, role, requested, created_at, updated_at from missionhub_20130829.group_memberships where group_id = #{group['id']}")
      #group_memberships.each do |ol|
        #sql = "insert into group_memberships(id, group_id, person_id, role, requested, created_at, updated_at) VALUES (#{ol['id']}, #{ol['group_id']}, #{ol['person_id']}, #{q(ol['role'])}, #{ol['requested']}, '#{ol['created_at']}', '#{ol['updated_at']}')"
        #puts sql
        #Organization.connection.insert(sql)
      #end
    #end

    Organization.connection.update("update interactions set organization_id = #{new_id} where organization_id = #{old_id}")

    #interactions = Label.connection.select_all("select id, #{new_id} as organization_id, interaction_type_id, receiver_id, created_by_id, updated_by_id, comment, privacy_setting, timestamp, deleted_at, created_at, updated_at from missionhub_20130829.interactions where organization_id = #{old_id}")
    #interactions.each do |ol|
      #sql = "insert into interactions(id, organization_id, interaction_type_id, receiver_id, created_by_id, updated_by_id, comment, privacy_setting, timestamp, deleted_at, created_at, updated_at) VALUES (#{ol['id']}, #{ol['organization_id']}, #{ol['interaction_type_id']}, #{ol['receiver_id']}, #{ol['created_by_id']}, #{ol['updated_by_id']}, #{q(ol['comment'])}, #{q(ol['privacy_setting'])}, '#{ol['timestamp']}', #{q(ol['deleted_at'])}, '#{ol['created_at']}', '#{ol['updated_at']}')"
      #puts sql
      #Organization.connection.insert(sql)
    #end

    #interactions.each do |interaction|
      #interaction_initiators = Label.connection.select_all("select id, person_id, interaction_id, created_at, updated_at from missionhub_20130829.interaction_initiators where interaction_id = #{interaction['id']}")
      #interaction_initiators.each do |ol|
        #sql = "insert into interaction_initiators(id, person_id, interaction_id, created_at, updated_at) VALUES (#{ol['id']}, #{ol['person_id']}, #{q(ol['interaction_id'])}, '#{ol['created_at']}', '#{ol['updated_at']}')"
        #puts sql
        #Organization.connection.insert(sql)
      #end
    #end

    Organization.connection.update("update organizational_permissions set organization_id = #{new_id} where organization_id = #{old_id}")

    #organizational_permissions = Organization.connection.select_all("select id, person_id, permission_id, #{new_id} as organization_id, followup_status, start_date, added_by_id, archive_date, created_at, updated_at from missionhub_20130829.organizational_permissions where organization_id = #{old_id}")
    #organizational_permissions.each do |ol|
      #sql = "insert into organizational_permissions(id, person_id, permission_id, organization_id, followup_status, start_date, added_by_id, archive_date, created_at, updated_at) VALUES (#{ol['id']}, #{ol['person_id']}, #{ol['permission_id']}, #{ol['organization_id']}, #{q(ol['followup_status'])}, #{q(ol['start_date'])}, #{ol['added_by_id']}, #{q(ol['archive_date'])}, '#{ol['created_at']}', '#{ol['updated_at']}')"
      #puts sql
      #Organization.connection.insert(sql)
    #end

    Organization.connection.update("update rejoicables set organization_id = #{new_id} where organization_id = #{old_id}")

    #rejoicables = Organization.connection.select_all("select id, person_id, created_by_id, #{new_id} as organization_id, followup_comment_id, what, deleted_at, created_at, updated_at from missionhub_20130829.rejoicables where organization_id = #{old_id}")
    #rejoicables.each do |ol|
      #sql = "insert into rejoicables(id, person_id, created_by_id, organization_id, followup_comment_id, what, deleted_at, created_at, updated_at) VALUES (#{ol['id']}, #{ol['person_id']}, #{ol['created_by_id']}, #{ol['organization_id']}, #{ol['followup_comment_id']}, #{q(ol['what'])}, #{q(ol['deleted_at'])}, '#{ol['created_at']}', '#{ol['updated_at']}')"
      #puts sql
      #Organization.connection.insert(sql)
    #end

    surveys = Organization.connection.select_all("select id, title, #{new_id} as organization_id, post_survey_message, terminology, login_option, is_frozen, login_paragraph, css, background_color, text_color, crs_registrant_type_id, redirect_url, created_at, updated_at from missionhub_20130829.surveys where organization_id = #{old_id}")
    surveys.each do |ol|
      sql = "insert into surveys(id, title, organization_id, post_survey_message, terminology, login_option, is_frozen, login_paragraph, css, background_color, text_color, crs_registrant_type_id, redirect_url, created_at, updated_at) VALUES (#{ol['id']}, #{q(ol['title'])}, #{ol['organization_id']}, #{q(ol['post_survey_message'])}, #{q(ol['terminology'])}, #{q(ol['login_option'])}, #{q(ol['is_frozen'])}, #{q(ol['login_paragraph'])}, #{q(ol['css'])}, #{q(ol['background_color'])}, #{q(ol['text_color'])}, #{q(ol['crs_registrant_type_id'])}, #{q(ol['redirect_url'])}, '#{ol['created_at']}', '#{ol['updated_at']}')"
      puts sql
      Organization.connection.insert(sql)
    end

    Organization.connection.update("update sms_keywords set organization_id = #{new_id} where organization_id = #{old_id}")

    #sms_keywords = Organization.connection.select_all("select id, keyword, event_id, #{new_id} as organization_id, chartfield, user_id, explanation, state, initial_response, event_type, gateway, survey_id, created_at, updated_at from missionhub_20130829.sms_keywords where organization_id = #{old_id}")
    #sms_keywords.each do |ol|
      #sql = "insert into sms_keywords(id, keyword, event_id, organization_id, chartfield, user_id, explanation, state, initial_response, event_type, gateway, survey_id, created_at, updated_at) VALUES (#{ol['id']}, #{q(ol['keyword'])}, #{q(ol['event_id'])}, #{ol['organization_id']}, #{q(ol['chartfield'])}, #{q(ol['user_id'])}, #{q(ol['explanation'])}, #{q(ol['state'])}, #{q(ol['initial_response'])}, #{q(ol['event_type'])}, #{q(ol['gateway'])}, #{q(ol['survey_id'])}, '#{ol['created_at']}', '#{ol['updated_at']}')"
      #puts sql
      #Organization.connection.insert(sql)
    #end

    #chart_organizations = Organization.connection.select_all("select id, chart_id, #{new_id} as organization_id, snapshot_display, created_at, updated_at from missionhub_20130829.chart_organizations where organization_id = #{old_id}")
    #chart_organizations.each do |ol|
      #sql = "insert into chart_organizations(id, chart_id, organization_id, snapshot_display, created_at, updated_at) VALUES (#{ol['id']}, #{ol['chart_id']}, #{ol['organization_id']}, #{q(ol['snapshot_display'])}, '#{ol['created_at']}', '#{ol['updated_at']}')"
      #puts sql
      #Organization.connection.insert(sql)
    #end

    Organization.connection.update("update saved_contact_searches set organization_id = #{new_id} where organization_id = #{old_id}")

    #saved_contact_searches = Organization.connection.select_all("select id, name, #{new_id} as organization_id, full_path, user_id, created_at, updated_at from missionhub_20130829.saved_contact_searches where organization_id = #{old_id}")
    #saved_contact_searches.each do |ol|
      #sql = "insert into saved_contact_searches(id, name, organization_id, full_path, user_id, created_at, updated_at) VALUES (#{ol['id']}, #{q(ol['name'])}, #{ol['organization_id']}, #{q(ol['user_id'])}, #{q(ol['full_path'])}, '#{ol['created_at']}', '#{ol['updated_at']}')"
      #puts sql
      #Organization.connection.insert(sql)
    #end
  end
end
