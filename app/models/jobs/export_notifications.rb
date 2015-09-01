class Jobs::ExportNotifications
  include Sidekiq::Worker
  sidekiq_options unique: true

  def perform(export_id)
    export = Export.find_by(id: export_id, status: 'pending')
    if export.present?
      category = export.category
      organization = export.organization
      person = export.person
      options = export.options

      case category
      when Export::CATEGORY_CSV
        if export.contacts? && organization.present? && person.present? && options.present?
          people_ids = options["person"]
          survey_ids = options["survey"]
          if people_ids.present?
            all_people = Person.where(id: people_ids)
            all_surveys = Survey.where(id: survey_ids) if survey_ids.present?
            all_questions = Export.get_all_questions(organization)
            all_answers = Export.generate_answers(people_ids, organization, all_questions, all_surveys)

            all_roles = Hash[OrganizationalPermission.active.where(organization_id: organization.id,
              person_id: all_people.collect(&:id)).map {|r| [r.person_id, r] if r.permission_id == Permission::NO_PERMISSIONS_ID }]
            csv = ContactsCsvGenerator.generate(all_roles, all_answers, all_questions, all_people, organization)
            begin
              ExportMailer.send_csv(csv, person, organization).deliver_now
              export.update(status: "sent")
            rescue
              export.update(status: "failed")
            end
          else
            export.update(status: "failed")
          end
        end
      end
    end
  end
end
