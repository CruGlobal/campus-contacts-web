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
    begin
      json = JSON.parse(response)
      carrier = normalize(json['allocation']['carrier_name'])
      PhoneNumber.connection.update("update phone_numbers set carrier = '#{carrier}' where number = '#{number}'")
    rescue
      # PhoneNumber.where(:number => number).collect(&:destroy)
    end
    time_to_sleep = rand(5) + 2
    puts "Sleeping #{time_to_sleep} seconds"
    sleep(time_to_sleep)
  end
end


def normalize(carrier)
  case carrier
  when /VERIZON/
    'verizon'
  when /SPRINT/
    'sprint'
  when /CINGULAR/
    'cingular'
  when /NEXTEL/
    'nextel'
  when /T-MOBILE/
    't-mobile'
  when /WESTERN WIRELESS/
    'western wireless'
  when /OMNIPOINT/
    'omnipoint'
  else
    carrier
  end
end