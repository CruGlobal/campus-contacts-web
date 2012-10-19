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
