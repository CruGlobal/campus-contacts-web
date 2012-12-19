require 'csv'
require 'open-uri'
require 'contact_methods'
class Import < ActiveRecord::Base
  include ContactMethods

  @queue = :general
  serialize :headers
  serialize :preview
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
    email_question = Element.where( :attribute_name => "email").first.id.to_s

    csv = CSV.new(open(upload.expiring_url), :headers => :first_row)

    csv.each do |row|
      person_hash = Hash.new
      person_hash[:person] = Hash.new
      person_hash[:person][:first_name] = row[header_mappings.invert[first_name_question].to_i]
      person_hash[:person][:email] = row[header_mappings.invert[email_question].to_i] if header_mappings.invert[email_question].present? && row[header_mappings.invert[email_question].to_i].present?

      answers = Hash.new

      header_mappings.keys.each do |k|
        answers[header_mappings[k].to_i] = row[k.to_i] unless header_mappings[k] == '' || header_mappings[k] == 'do_not_import'
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
    do_not_import_count = a.count('do_not_import')
    do_not_import_count -= 1 if do_not_import_count > 0
    if a.length > (a.uniq.length + do_not_import_count) # if they don't have the same length that means the user has selected on at least two of the headers the same selected person attribute/survey question
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
        person = create_contact_from_row(new_person, current_organization)
        new_person_ids << person.id
        names << person.name
        if person.errors.present?
          person.errors.messages.each do |error|
            import_errors << "#{person.to_s}: #{error[0].to_s.split('.')[0].gsub('_',' ').titleize} #{error[1].first}"
          end
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
        table = create_table(new_person_ids)
        ImportMailer.import_successful(current_user, table).deliver
      end
    end
  end

  def create_contact_from_row(row, current_organization)
    person = Person.find_existing_person(Person.new(row[:person]))
    person.save

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
    predefined = Survey.find(APP_CONFIG['predefined_survey'])
    predefined.elements.where('object_name is not null').each do |question|
      question.set_response(row[:answers][question.id], answer_sheet)
    end

    if person.save
      question_sets.map { |qs| qs.save }
      contact_role = create_contact_at_org(person, current_organization)
      # contact_role.update_attribute('followup_status','uncontacted') # Set default
    end

    return person
  end

  class NilColumnHeader < StandardError

  end

  private

  def create_table(new_person_ids)
    @answered_question_ids = header_mappings.values.reject{ |c| c.empty? || c == 'do_not_import' }.collect(&:to_i)
    #puts answered_question_ids.inspect
    predefined_question_ids = Survey.find(APP_CONFIG['predefined_survey']).elements.collect(&:id)
    #puts Survey.find(APP_CONFIG['predefined_survey']).elements.inspect
    answered_survey_ids = SurveyElement.where(element_id: @answered_question_ids).pluck(:survey_id).uniq
    #answer_sheet_ids = AnswerSheet.where(survey_id: answered_survey_ids)

    @table = []
    title = []
    @answered_question_ids.each do |a|
      title << Element.find(a).label
    end

    @table << title

    Person.find(new_person_ids).each do |p|
      answers = []
      answer_sheet_ids = p.answer_sheets.where(survey_id: answered_survey_ids).collect(&:id)
      @answered_question_ids.each do |a|

        if predefined_question_ids.include? a
          answers << p.send(Element.find(a).attribute_name)
        else
          a = Answer.where(question_id: a, answer_sheet_id: answer_sheet_ids).first.nil? ? "" : Answer.where(question_id: a, answer_sheet_id: answer_sheet_ids).first.value

          answers << a
        end
      end
      @table << answers
    end
    @table
  end

  def parse_headers
    return unless upload?
    tempfile = upload.queued_for_write[:original]
    unless tempfile.nil?
      ctr = 0
      CSV.foreach(tempfile.path) do |row|
        Rails.logger.info "---COLLECT#{ctr}---"
        if ctr == 0
          begin
            # if there is a nil headers
            raise NilColumnHeader if row && row.length - row.compact.length != 0
            self.headers = row.compact
          rescue
            raise NilColumnHeader
          end
          raise NilColumnHeader if headers.empty?
        elsif ctr == 1
          self.preview = row
        else
          break
        end
        ctr += 1
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
