require 'csv'
require 'open-uri'
require 'contact_methods'
require 'async'
class Import < ActiveRecord::Base
  attr_accessible :user_id, :organization_id, :survey_ids, :upload, :headers, :header_mappings, :preview

  include Async
  include Sidekiq::Worker
  include ContactMethods
  sidekiq_options unique: true

  serialize :survey_ids, Array
  serialize :headers
  serialize :preview
  serialize :header_mappings

  belongs_to :user
  belongs_to :organization

  has_attached_file :upload, s3_permissions: :private, storage: :s3,
                             path: 'mh/imports/:attachment/:id/:filename', s3_storage_class: :reduced_redundancy,
                             s3_credentials: { bucket: ENV['AWS_BUCKET'], access_key_id: ENV['AWS_ACCESS_KEY_ID'],
                                               secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'] }

  validates_attachment_file_name :upload, matches: [/csv\Z/]

  validates :upload, attachment_presence: true

  before_save :parse_headers

  def label_name
    created_at.strftime('Import-%Y-%m-%d')
  end

  def first_name_question_id
    Element.find_by(attribute_name: 'first_name')
      .survey_elements.find_by(survey_id: ENV['PREDEFINED_SURVEY']).id.to_s
  end

  def get_new_people # generates array of Person hashes
    new_people = []
    first_name_col = nil
    header_mappings.each do |col, se_id|
      first_name_col = col.to_i if se_id == first_name_question_id
    end
    email_question_id = Element.find_by(attribute_name: 'email')
                        .survey_elements.find_by(survey_id: ENV['PREDEFINED_SURVEY']).id.to_s
    email_col = nil
    header_mappings.each do |col, se_id|
      email_col = col.to_i if se_id == email_question_id
    end

    file = URI.parse(upload.expiring_url).read.encode('utf-8', 'iso-8859-1')
    content = CSV.new(file, headers: :first_row)

    content.each do |row|
      person_hash = {}
      person_hash[:person] = {}
      person_hash[:person][:first_name] = row[first_name_col]
      person_hash[:person][:email] = row[email_col] if row[email_col].present?

      answers = {}
      header_mappings.each do |col, se|
        answers[se.to_i] = row[col.to_i] unless se == '' || se == 'do_not_import'
      end
      person_hash[:answers] = answers

      new_people << person_hash
    end

    new_people
  end

  def check_for_errors # validating csv
    errors = []

    # since first name is required for every contact. Look for id of element where
    # attribute_name = 'first_name' in the header_mappings.
    has_header = header_mappings.any? do |_col, se|
      se == first_name_question_id
    end
    errors << I18n.t('contacts.import_contacts.present_first_name') unless has_header

    a = header_mappings.values
    a.delete('')
    do_not_import_count = a.count('do_not_import')
    do_not_import_count -= 1 if do_not_import_count > 0
    # if they don't have the same length that means the user has selected on at least two of the
    # headers the same selected person attribute/survey question
    if a.length > (a.uniq.length + do_not_import_count)
      return errors << I18n.t('contacts.import_contacts.duplicate_header_match')
    end
    errors
  end

  def queue_import_contacts(labels = [])
    async(:do_import, labels)
  end

  def do_import(labels = [])
    current_organization = Organization.find(organization_id)
    current_user = User.find(user_id)
    import_errors = []
    names = []
    new_person_ids = []
    Person.transaction do
      get_new_people.each do |new_person|
        person = create_contact_from_row(new_person, current_organization, current_user.person.id)
        new_person_ids << person.id
        names << person.name
        if person.errors.present?
          person.errors.messages.each do |error|
            import_errors << "#{person}: #{error[0].to_s.split('.')[0].titleize} #{error[1].first}"
          end
        else
          labels.each do |label_id|
            if label_id.to_i == 0
              label = Label.where(organization_id: current_organization.id, name: label_name).first_or_create
              label_id = label.id
            elsif label_id.to_i == Label::LEADER_ID
              import_errors << "#{person}: Email address is required to add Leader label" unless person.email_addresses.present?
            end
            unless import_errors.present?
              current_organization.add_contact(person, current_user.person.id)
              current_organization.add_label_to_person(person, label_id, current_user.person.id)
            end
          end
        end
      end
      if import_errors.present?
        # send failure email
        ImportMailer.import_failed(current_user, import_errors).deliver_now
        fail ActiveRecord::Rollback
      else
        # Send success email
        table = create_table(new_person_ids, get_new_people)
        ImportMailer.import_successful(current_user, table).deliver_now
      end
    end
    if survey_ids.present? && import_errors.present?
      Survey.where(id: survey_ids).destroy_all
    end
  end

  def create_contact_from_row(row, current_organization, added_by_id = nil)
    row[:person] = row[:person].each_value { |p| p.strip! if p.present? }
    row[:answers] = row[:answers].each_value { |a| a.strip! if a.present? }

    person = Person.find_existing_person(Person.new(row[:person]))
    person.save

    unless @surveys_for_import
      @survey_ids ||= SurveyElement.where(id: row[:answers].keys).pluck(:survey_id) - [ENV.fetch('PREDEFINED_SURVEY')]
      @surveys_for_import = current_organization.surveys.where(id: @survey_ids.uniq)
    end

    question_sets = []

    @surveys_for_import.each do |survey|
      answer_sheet = get_answer_sheet(survey, person)
      question_set = QuestionSet.new(survey.questions, answer_sheet)
      element_responses = row[:answers].map { |k, v| [SurveyElement.find(k).element_id, v] }
      question_set.post(element_responses, answer_sheet)
      question_sets << question_set
    end

    new_phone_numbers = []
    # Set values for predefined questions
    answer_sheet = AnswerSheet.new(person_id: person.id)
    SurveyElement.where(survey_id: ENV.fetch('PREDEFINED_SURVEY')).joins(:element).where.not(elements: { object_name: nil }).each do |se|
      question = se.element
      answer = row[:answers][se.id]
      if answer.present?

        # create unique phone number but not a primary
        if question.attribute_name == 'phone_number'
          if person.phone_numbers.where(phone_numbers: { primary: true }).present?
            unless person.phone_numbers.where(phone_numbers: { number: answer }).present?
              new_phone_numbers << person.phone_numbers.new(number: answer, primary: false)
            end
          else
            unless person.phone_numbers.where(phone_numbers: { number: answer }).present?
              new_phone_numbers << person.phone_numbers.new(number: answer, primary: true)
            end
          end
        else
          # set response
          question.set_response(answer, answer_sheet)
        end
      end
    end

    if person.save
      question_sets.map(&:save)
      new_phone_numbers.map { |pn| pn.save if pn.number.present? }
      create_contact_at_org(person, current_organization, added_by_id)
    end

    person
  end

  class NilColumnHeader < StandardError
  end

  class InvalidCSVFormat < StandardError
  end

  private

  def create_table(_new_person_ids, excel_answers)
    @answered_question_ids = header_mappings.values.reject { |c| c.empty? || c == 'do_not_import' }.collect(&:to_i)

    @table = []
    questions = []
    @answered_question_ids.each do |a|
      questions << SurveyElement.find(a).element.label
    end
    @table << questions

    if excel_answers.present?
      excel_answers.each do |new_person|
        all_answers = []
        @answered_question_ids.each do |se|
          all_answers << new_person[:answers][se]
        end
        @table << all_answers
      end
    end
    @table
  end

  def parse_headers
    return unless upload?
    tempfile = upload.queued_for_write[:original]

    # Since we have to encode the csv file to avoid the "invalid byte sequence in utf-8" error
    # And import has no format validation, this line is the safest and lightest format validation
    # Rather than to set the validation from model, it's too strict.
    fail InvalidCSVFormat unless File.extname(upload.original_filename) == '.csv'

    return if tempfile.nil?

    CSV.foreach(tempfile.path, 'r:iso-8859-1:utf-8').each_with_index do |row, index|
      Rails.logger.info "---COLLECT#{index}---"
      break if index > 1
      if index == 0
        begin
          row.pop while row.length > 0 && row.last.blank?
          # if there is a nil headers
          fail NilColumnHeader if row && row.length - row.compact.length != 0
          self.headers = row.compact
        rescue
          raise NilColumnHeader
        end
        fail NilColumnHeader if headers.empty?
      elsif index == 1
        self.preview = row
      end
    end
  end

  def is_row_blank?(row)
    # checking if a row has no entries (because of the possibility of user entering in a blank row in a csv file)
    row.each do |r|
      return false unless r.nil?
    end
    true
  end
end
