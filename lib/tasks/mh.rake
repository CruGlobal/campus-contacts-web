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