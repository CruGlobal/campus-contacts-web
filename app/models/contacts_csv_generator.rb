require 'csv'
class ContactsCsvGenerator

  def self.generate(roles, all_answers, questions, people, organization)
    out = ""
    CSV.generate(out) do |rows|
      rows << [t('contacts.index.first_name'), t('contacts.index.last_name'), t('general.status'), t('general.assigned_to'), t('general.gender'), t('contacts.index.phone_number'), t('people.index.email')] + questions.collect {|q| q.label} + [t('contacts.index.last_survey')]
      people.each do |person|
        if roles[person.id]
          answers = [person.first_name, person.last_name, roles[person.id].followup_status.to_s.titleize, person.assigned_tos_by_org(organization).collect{|a| Person.find(a.assigned_to_id).name}.join(','), person.gender.to_s.titleize, person.pretty_phone_number, person.email]
          dates = []
          questions.each do |q|
            answer = all_answers[person.id][q.id]
            if answer
              answers << answer.first
              dates << answer.last
            else
              answers << ''
            end
          end
          answers << I18n.l(dates.sort.reverse.last, format: :date) if dates.present?
          rows << answers
        end
      end
    end
    out
  end

  def self.t(val)
    I18n.t(val)
  end

end
