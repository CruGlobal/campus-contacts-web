class Export < ActiveRecord::Base
  KIND_CONTACTS = "contacts"
  CATEGORY_CSV = "csv"

  attr_accessible :person_id, :organization_id, :category, :kind, :options, :status

  belongs_to :person
  belongs_to :organization
  serialize :options, Hash

  def contacts?
    kind == KIND_CONTACTS
  end

  def self.add(person, org, category = CATEGORY_CSV, kind = KIND_CONTACTS, options = {})
    export = org.exports.create(person_id: person.id, category: category, kind: kind, options: options)
    #begin
      Jobs::ExportNotifications.perform_async(export.id)
    #rescue;end
  end

  def self.build_options(args = Array.new)
    opts = Hash.new
    args.each do |objects|
      opts[objects.first.class.to_s.downcase] = objects.map {|obj| obj.id} if objects.present?
    end if args.present?
    opts
  end

  def self.generate_answers(people_ids, organization, questions, surveys = nil)
    answers = {}
    survey_ids = surveys.present? ? surveys.collect(&:id) : organization.survey_ids
    people_ids.each do |id|
      answers[id] = {}
    end
    surveys = {}

    answer_sheets = AnswerSheet.where(survey_id: survey_ids, person_id: people_ids)
      .includes(:survey, :answers, {:person => :primary_email_address})

    if answer_sheets.present?
      answer_sheets.each do |answer_sheet|
        surveys[answer_sheet.person_id] ||= {}
        surveys[answer_sheet.person_id][answer_sheet.survey] = answer_sheet.completed_at

        answers[answer_sheet.person_id] ||= {}
        questions.each do |q|
          if q.display_response(answer_sheet).present?
            answers[answer_sheet.person_id][q.id] = [q.display_response(answer_sheet), answer_sheet.updated_at]
          end
        end
      end
    end
    answers
  end

  def self.get_all_questions(organization)
    all_questions = organization.questions
    predefined_survey = Survey.find(ENV.fetch('PREDEFINED_SURVEY'))
    excepted_predefined_fields = ['first_name','last_name','gender','phone_number']
    predefined_questions = organization.predefined_survey_questions.where("attribute_name NOT IN (?)", excepted_predefined_fields)
    questions = (all_questions.where("survey_elements.hidden = ?", false) + predefined_questions.where(id: organization.settings[:visible_predefined_questions])).uniq
    questions.select! { |q| !%w{first_name last_name phone_number email}.include?(q.attribute_name) }
  end
end
