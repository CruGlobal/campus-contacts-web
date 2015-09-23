require 'csv'
class ContactsCsvGenerator

  def self.generate(permissions, all_answers, questions, people, organization)
    out = ""
    CSV.generate(out) do |rows|
      question_labels = questions.present? ? questions.collect {|q| q.label} : []
      rows << [t('contacts.index.first_name'), t('contacts.index.last_name'), t('general.status'), t('general.assigned_to'), t('general.gender'), t('contacts.index.phone_number'), t('people.index.email')] + question_labels + [t('contacts.index.last_survey')]
      people.each do |person|
        answers = [person.first_name, person.last_name, permissions[person.id].present? ? permissions[person.id].followup_status.to_s.titleize : nil, person.assigned_tos_by_org(organization).collect{|a| Person.find(a.assigned_to_id).name}.join(','), person.gender.to_s.titleize, person.pretty_phone_number, person.email]

        if questions.present?
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

  def self.export_signatures(person_signatures)
    out = ""
    CSV.generate(out) do |rows|
      rows << [t("general.first_name"), t("general.last_name"), t("signatures.code_of_conduct.title"), t("signatures.statement_of_faith.title"), t("general.organization"), t("signatures.date_signed_at")]
      person_signatures.includes(:person, :organization).each do |person_signature|
        fname = person_signature.person.first_name
        lname = person_signature.person.last_name
        code_of_conduct_status = person_signature.signature_status(Signature::SIGNATURE_CODE_OF_CONDUCT).try(:humanize)
        statement_of_faith_status = person_signature.signature_status(Signature::SIGNATURE_STATEMENT_OF_FAITH).try(:humanize)
        org_name = person_signature.organization.name
        date_signed = person_signature.date_signed_at.present? ? I18n.l(person_signature.date_signed_at, format: :date) : ""
        rows << [fname, lname, code_of_conduct_status, statement_of_faith_status, org_name, date_signed]
      end
    end
    out
  end
end