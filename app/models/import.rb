require 'csv'
require 'open-uri'
require 'contact_methods'
class Import < ActiveRecord::Base
  include ContactMethods

  @queue = :general
  serialize :headers
  serialize :header_mappings

  belongs_to :user
  belongs_to :organization

  has_attached_file :upload, s3_credentials: 'config/s3.yml', s3_permissions: :private, storage: :s3,
                             path: 'mh/imports/:attachment/:id/:filename', s3_storage_class: :reduced_redundancy

  validates :upload, attachment_presence: true

  before_save :parse_headers
  
  def label_name
    created_at.strftime("Import-%Y-%m-%d")
  end

  def get_new_people # generates array of Person hashes
    new_people = Array.new
    first_name_question = Element.where( :attribute_name => "first_name").first.id.to_s

    csv = CSV.new(open(upload.expiring_url), :headers => :first_row)

    csv.each do |row|
      person_hash = Hash.new
      person_hash[:person] = Hash.new
      person_hash[:person][:first_name] = row[header_mappings.invert[first_name_question].to_i]

      answers = Hash.new

      header_mappings.keys.each do |k|
        answers[header_mappings[k].to_i] = row[k.to_i] unless header_mappings[k] == ''
      end

      person_hash[:answers] = answers
      new_people << person_hash
    end

    new_people

  end

  def check_for_errors # validating csv
    errors = []

    #since first name is required for every contact. Look for id of element where attribute_name = 'first_name' in the header_mappings.
    first_name_question = Element.where(:attribute_name => "first_name").first.id.to_s
    unless header_mappings.values.include?(first_name_question) 
      errors << I18n.t('contacts.import_contacts.present_first_name')
    end

    a = header_mappings.values
    a.delete("")
    if a.length > a.uniq.length # if they don't have the same length that means the user has selected on at least two of the headers the same selected person attribute/survey question
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
    Person.transaction do
      get_new_people.each do |new_person|
        person = create_contact_from_row(new_person, current_organization)
        if person.errors.present?
          import_errors << "#{person.to_s}: #{person.errors.full_messages.join(', ')}"
        else
          labels.each do |role_id|
            if role_id.to_i == 0
              role = Role.find_or_create_by_organization_id_and_name(current_organization.id, label_name)
              role_id = role.id
            end
            current_organization.add_role_to_person(person, role_id)
          end
        end
      end
      if import_errors.present?
        # send failure email
        ImportMailer.import_failed(current_user, import_errors).deliver
        raise ActiveRecord::Rollback
      else
        # Send success email
        ImportMailer.import_successful(current_user).deliver
      end
    end

  end
  
  def create_contact_from_row(row, current_organization)
    person = Person.create!(row[:person])
    
    unless @surveys_for_import
      @survey_ids ||= SurveyElement.where(element_id: row[:answers].keys).pluck(:survey_id) - [APP_CONFIG['predefined_survey']]
      @surveys_for_import = current_organization.surveys.where(id: @survey_ids.uniq)
    end

    question_sets = []

    @surveys_for_import.each do |survey|
      answer_sheet = get_answer_sheet(survey, person)
      question_set = QuestionSet.new(survey.questions, answer_sheet)
      question_set.post(row[:answers], answer_sheet)
      question_sets << question_set
    end

    # Set values for predefined questions
    answer_sheet = AnswerSheet.new(person: person)
    predefined =
      begin
        Survey.find(APP_CONFIG['predefined_survey'])
      rescue
        Survey.find(2)
      end
    predefined.elements.where('object_name is not null').each do |question|
      question.set_response(row[:answers][question.id], answer_sheet)
    end

    person, email, phone = Person.find_existing_person(person)

    if person.save
      question_sets.map { |qs| qs.save }
      create_contact_at_org(person, current_organization)
    end

    return person
  end

  class NilColumnHeader < StandardError

  end

  private

  def parse_headers
    return unless upload?
    tempfile = upload.queued_for_write[:original]
    unless tempfile.nil?
      File.open(tempfile.path) do |f|
        csv = CSV.new(f, :headers => :first_row)
        csv.shift
        begin
          raise NilColumnHeader if csv.headers && csv.headers.length - csv.headers.compact.length != 0 #if there is a nil headers
          self.headers = csv.headers.compact
        rescue
          raise NilColumnHeader
        end
        raise NilColumnHeader if headers.empty?
      end
    end
  end

  def is_row_blank?(row)
    #checking if a row has no entries (because of the possibility of user entering in a blank row in a csv file)
    row.each do |r|
      return false if !r.nil?
    end
    true
  end
  
end
