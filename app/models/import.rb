require 'csv'
require 'open-uri'
class Import < ActiveRecord::Base
  self.table_name = 'mh_imports'

  serialize :headers
  serialize :header_mappings

  belongs_to :user
  belongs_to :organization

  has_attached_file :upload, s3_credentials: 'config/s3.yml', s3_permissions: :private, storage: :s3,
                             path: 'mh/imports/:attachment/:id/:filename', s3_storage_class: :reduced_redundancy

  validates :upload, attachment_presence: true

  before_save :parse_headers

  def get_new_people # generates array of Person hashes
    new_people = Array.new
    first_name_question = Element.where( :attribute_name => "firstName").first.id.to_s

    csv = CSV.new(open(upload.expiring_url), :headers => :first_row)

    csv.each do |row|
      person_hash = Hash.new
      person_hash[:person] = Hash.new
      person_hash[:person][:firstName] = row[header_mappings.invert[first_name_question].to_i]

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

    #since first name is required for every contact. Look for id of element where attribute_name = 'firstName' in the header_mappings.
    first_name_question = Element.where( :attribute_name => "firstName").first.id.to_s
    unless header_mappings.values.include?(first_name_question) 
      errors << I18n.t('contacts.import_contacts.present_firstname')
    end

    a = header_mappings.values
    a.delete("")
    if a.length > a.uniq.length # if they don't have the same length that means the user has selected on at least two of the headers the same selected person attribute/survey question
      return errors << I18n.t('contacts.import_contacts.duplicate_header_match')
    end
    errors
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
        self.headers = csv.headers.compact
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
