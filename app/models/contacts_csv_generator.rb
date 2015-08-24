require 'csv'
class ContactsCsvGenerator

  def self.generate(permissions, all_answers, questions, people, organization)
    out = ""
    CSV.generate(out) do |rows|
      rows << [t('contacts.index.first_name'), t('contacts.index.last_name'), t('general.status'), t('general.assigned_to'), t('general.gender'), t('contacts.index.phone_number'), t('people.index.email')] + questions.collect {|q| q.label} + [t('contacts.index.last_survey')]
      people.each do |person|
        answers = [person.first_name, person.last_name, permissions[person.id].present? ? permissions[person.id].followup_status.to_s.titleize : nil, person.assigned_tos_by_org(organization).collect{|a| Person.find(a.assigned_to_id).name}.join(','), person.gender.to_s.titleize, person.pretty_phone_number, person.email]
        questions.each do |q|
          answer = all_answers[person.id][q.id]
          if q.slug == 'email'
            answers << person.email
          elsif q.object_name == 'person'
            answers << person.send(:"#{q.attribute_name}")
          else
            if answer
              answers << answer.first
            else
              answers << ''
            end
          end
        end
        last_answer_sheet = person.completed_answer_sheets(organization)
        answers << I18n.l(last_answer_sheet.first.updated_at, format: :date) if last_answer_sheet.present?
        rows << answers
      end
    end
    out
  end

  def self.t(val)
    I18n.t(val)
  end
end