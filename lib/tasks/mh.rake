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
  PhoneNumber.connection.select_values("select distinct(number) as number from phone_numbers where txt_to_email is null or txt_to_email = ''").each do |number|
    puts number
    next unless number.length == 10
    url = "https://api.data24-7.com/textat.php?username=support@missionhub.com&password=Windows7&p1=#{number}"
    xml = Nokogiri::XML(open(url))
    begin
      email = xml.xpath('.//sms_address').text
      carrier_name = xml.xpath('.//carrier_name').text
      carrier = SmsCarrier.find_or_create_by_data247_name(normalize_carrier(carrier_name))
      PhoneNumber.connection.update("update phone_numbers set carrier_id = #{carrier.id}, txt_to_email = '#{email}', email_updated_at = '#{Time.now.to_s(:db)}' where number = '#{number}'")
    rescue
      raise xml.inspect
    end
    # time_to_sleep = rand(5) + 2
    # puts "Sleeping #{time_to_sleep} seconds"
    # sleep(time_to_sleep)
  end
end