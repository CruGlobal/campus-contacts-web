require 'csv'
require 'open-uri'
class Import < ActiveRecord::Base
  self.table_name = 'mh_imports'

  serialize :headers
  serialize :header_mappings

  belongs_to :user
  belongs_to :organization

  has_attached_file :upload, s3_credentials: 'config/s3.yml', s3_permissions: :private, bucket: 'dev',
                             path: 'mh/imports/:attachment/:id/:filename', s3_storage_class: :reduced_redundancy

  before_save :parse_headers

  HEADERS = {" " => nil, "First Name"	=> "firstName", "Last Name"	=> "lastName",	"Status"	=> "status",	"Gender"	=> "gender",	"Email Address"	=> "email",	"Phone Number"	=> "phone_number",	"Address 1"	=> "address1", "Address 2"	=> "address2", "City"	=> "city", "State"	=> "state", "Country"	=> "country", "Zip"	=> "zip"}

  def get_new_people # generates array of Person hashes
    new_people = Array.new

    csv = CSV.readlines(upload.path)
    csv.shift #skip headers

    csv.each do |row|
      person_hash = Hash.new
      person_hash[:person] = Hash.new
      person_hash[:person][:firstName] = row[header_mappings.invert[HEADERS["First Name"]].to_i] if header_mappings.values.include?(HEADERS["First Name"])
      person_hash[:person][:lastName] = row[header_mappings.invert[HEADERS["Last Name"]].to_i] if header_mappings.values.include?(HEADERS["Last Name"])
      person_hash[:person][:gender] = row[header_mappings.invert[HEADERS["Gender"]].to_i] if header_mappings.values.include?(HEADERS["Gender"])
      person_hash[:person][:email_address] = {:email => row[header_mappings.invert[HEADERS["Email Address"]].to_i], :primary => "1", :_destroy => "false"} if header_mappings.values.include?(HEADERS["Email Address"])
      person_hash[:person][:phone_number] = {:number => row[header_mappings.invert[HEADERS["Phone Number"]].to_i], :location => "mobile", :primary => "1", :_destroy => "false"} if header_mappings.values.include?(HEADERS["Phone Number"])
      person_hash[:person][:current_address_attributes] = Hash.new
      person_hash[:person][:current_address_attributes][:address1] = row[header_mappings.invert[HEADERS["Address 1"]].to_i] if header_mappings.values.include?(HEADERS["Address 1"])
      person_hash[:person][:current_address_attributes][:address2] = row[header_mappings.invert[HEADERS["Address 2"]].to_i] if header_mappings.values.include?(HEADERS["Address 2"])
      person_hash[:person][:current_address_attributes][:city] = row[header_mappings.invert[HEADERS["City"]].to_i] if header_mappings.values.include?(HEADERS["City"])
      person_hash[:person][:current_address_attributes][:state] = row[header_mappings.invert[HEADERS["State"]].to_i] if header_mappings.values.include?(HEADERS["State"])
      person_hash[:person][:current_address_attributes][:country] = row[header_mappings.invert[HEADERS["Country"]].to_i] if header_mappings.values.include?(HEADERS["Country"])
      person_hash[:person][:current_address_attributes][:zip] = row[header_mappings.invert[HEADERS["Zip"]].to_i] if header_mappings.values.include?(HEADERS["Zip"])

      new_people << person_hash
    end

    new_people
  end

  def check_for_errors # validating csv
    errors = []

    flash_error = ""
    flash_error_first_name = "#{I18n.t('contacts.import_contacts.cause_1')}"
    flash_error_phone_no_format = "#{I18n.t('contacts.import_contacts.cause_2')}"
    flash_error_email_format = "#{I18n.t('contacts.import_contacts.cause_3')}"

    unless header_mappings.values.include?(HEADERS["First Name"]) #since first name is required for every contact
      return errors << I18n.t('contacts.import_contacts.present_firstname')
    end

    csv = CSV.readlines(upload.path)
    csv.shift #skip headers

    csv.each_with_index do |row, i| # every csv rows
      next if is_row_blank?(row) # skip headers or skip blank row
      # if firstName is blank
      if !row[header_mappings.invert[HEADERS["First Name"]].to_i].to_s.match /[a-z]/ 
        flash_error_first_name = flash_error_first_name + " #{i+2}, "
      end
      # row number of phone number in csv file
      phone_r = header_mappings.invert[HEADERS["Phone Number"]].to_i
      if header_mappings.values.include?(HEADERS["Phone Number"]) && row[phone_r].to_s.gsub(/[^\d]/,'').length < 7 && !row[phone_r].nil? # if phone_number length < 7
        flash_error_phone_no_format = flash_error_phone_no_format + " #{i+2}, "
      end
       # if email has wrong formatting
      if header_mappings.values.include?(HEADERS["Email Address"]) && !row[header_mappings.invert[HEADERS["Email Address"]].to_i].to_s.match(/^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i)
        flash_error_email_format = flash_error_email_format + " #{i+2}, "
      end
    end

    errors << flash_error_first_name.gsub(/,\s$/, '') if flash_error_first_name.include?(',')
    errors << flash_error_phone_no_format.gsub(/,\s$/, '') if flash_error_phone_no_format.include?(',')
    errors << flash_error_email_format.gsub(/,\s$/, '') if flash_error_email_format.include?(',')
    errors.insert(0, I18n.t('contacts.import_contacts.error')) unless errors.blank?
  end

  class NilColumnHeader < StandardError

  end

  private

  def parse_headers
    return unless upload?
    tempfile = upload.queued_for_write[:original]
    unless tempfile.nil?
      csv = CSV.new(tempfile, :headers => :first_row)
      csv.shift
      raise NilColumnHeader if csv.headers.include?(nil)
      self.headers = csv.headers
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
