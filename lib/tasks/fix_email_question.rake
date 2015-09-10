# rake fix_emails question_id=29247

task :fix_emails => :environment do
  question_id = ENV['question_id']
  total_records = 0
  emails_added = 0
  Answer.where(question_id: question_id).includes(answer_sheet: :person).find_each do |answer|
    total_records = total_records + 1
    p total_records if total_records % 50 == 0
    person = answer.answer_sheet.person
    next if person.blank? || person.email_addresses.where(email: answer.value).any?
    person.add_email(answer.value)
    emails_added = emails_added + 1
  end
  p "processed #{total_records}, added #{emails_added} emails"
end
