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
  uri = URI.parse('http://www.freerevcell.com/index.php')
  PhoneNumber.connection.select_values('select distinct(number) as number from phone_numbers').each do |number|
    body = Net::HTTP.post_form(uri, { :num => number, :do2 => 'Checking..Wait' }).body
    m = body.match(/(#{number}@.*) </)
    txt_to_email = m ? m[1] : ''
    m = body.match(/<b>(.*) <\/b><\/font><\/td>/)
    carrier = m ? m[1] : ''
    PhoneNumber.connection.update("update phone_numbers set txt_to_email = '#{txt_to_email}', carrier = '#{carrier}' where number = '#{number}'")
    time_to_sleep = rand(5)
    puts "Sleeping #{time_to_sleep} seconds"
    sleep(time_to_sleep)
  end
end
