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
  require 'net/http'
  PhoneNumber.connection.select_values("select distinct(number) as number from phone_numbers where carrier is null or carrier = ''").each do |number|
    uri = URI.parse("http://digits.cloudvox.com/#{number}.json")
    response = Net::HTTP.get(uri)
    puts response
    json = JSON.parse(response)
    PhoneNumber.connection.update("update phone_numbers set txt_to_email = carrier = '#{json['allocation']['carrier_name']}' where number = '#{number}'")
    time_to_sleep = rand(5) + 2
    puts "Sleeping #{time_to_sleep} seconds"
    sleep(time_to_sleep)
  end
end
