require 'csv'
require 'open-uri'
class Import < ActiveRecord::Base
  self.table_name = 'mh_imports'

  serialize :headers
  serialize :header_mappings

  belongs_to :user
  belongs_to :organization

  has_attached_file :upload, s3_credentials: 'config/s3.yml', s3_permissions: :private,
                             path: 'mh/imports/:attachment/:id/:filename', s3_storage_class: :reduced_redundancy

  before_save :parse_headers

  def get_new_people # generates array of Person hashes
    new_people = Array.new

    csv = CSV.readlines(upload.path)
    csv.shift #skip headers

    csv.each do |row|
      person_hash = Hash.new
      person_hash[:person] = Hash.new
      person_hash[:person][:firstName] = row[header_mappings.invert[Element.where(:attribute_name => "firstName").first.id.to_s].to_i]

      answers = Hash.new

      header_mappings.keys.each do |k|
        answers[header_mappings[k].to_i] = row[k.to_i] unless header_mappings[k] == ''
      end

      person_hash[:answers] = answers
      puts person_hash
      new_people << person_hash
    end

  new_people

  end

  def check_for_errors # validating csv
    errors = []

    unless header_mappings.values.include?(Element.where( :attribute_name => "firstName").first.id.to_s) #since first name is required for every contact. Look for id of element where attribute_name = 'firstName' in the header_mappings.
      errors << I18n.t('contacts.import_contacts.present_firstname')
    end

    a = header_mappings.values
    puts a
    a.delete("")
    puts a
    if a.length > a.uniq.length # if they don't have the same length that means the user has selected on at least two of the headers the same selected person attribute/survey question
      return errors << I18n.t('contacts.import_contacts.duplicate_header_match')
    end

=begin
    flash_error = ""
    flash_error_phone_no_format = "#{I18n.t('contacts.import_contacts.cause_2')}"
    flash_error_email_format = "#{I18n.t('contacts.import_contacts.cause_3')}"

    csv = CSV.readlines(upload.path)
    csv.shift #skip headers

    csv.each_with_index do |row, i| # every csv rows
      next if is_row_blank?(row) # skip headers or skip blank row

      # row number of phone number in csv file
      if Element.where(:attribute_name => "phone_number")
        phone_r = header_mappings.invert[Element.where(:attribute_name => "phone_number").id.to_s].to_i
        if header_mappings.values.include?(Element.where(:attribute_name => "phone_number").id.to_s) && row[phone_r].to_s.gsub(/[^\d]/,'').length < 7 && !row[phone_r].nil? # if phone_number length < 7
         flash_error_phone_no_format = flash_error_phone_no_format + " #{i+2}, "
        end
      end
      # if email has wrong formatting
      if Element.where(:attribute_name => "email")
        if header_mappings.values.include?(Element.where(:attribute_name => "email").id.to_s) && !row[header_mappings.invert[Element.where(:attribute_name => "email").id.to_s].to_i].match(/^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i)
         flash_error_email_format = flash_error_email_format + " #{i+2}, "
        end
      end
    end

    errors << flash_error_phone_no_format.gsub(/,\s$/, '') if flash_error_phone_no_format.include?(',')
    errors << flash_error_email_format.gsub(/,\s$/, '') if flash_error_email_format.include?(',')
    errors.insert(0, I18n.t('contacts.import_contacts.error')) unless errors.blank?
=end
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
        raise NilColumnHeader if csv.headers.include?(nil)
        self.headers = csv.headers
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
