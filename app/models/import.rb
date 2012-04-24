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

  HEADERS = {"First Name"	=> "firstName", "Last Name"	=> "lastName",	"Status"	=> "status",	"Gender"	=> "gender",	"Email Address"	=> "email",	"Phone Number"	=> "phone_number",	"Address 1"	=> "address1", "Address 2"	=> "address2", "City"	=> "city", "State"	=> "state", "Country"	=> "country", "Zip"	=> "zip"}

  def import
    # TODO: perform actual import
  end

  def check_for_errors
    errors = []
    # TODO: validate csv

    errors
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
end
