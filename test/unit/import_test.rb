require 'test_helper'

class ImportTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  
  setup do    
    @user = Factory(:user_with_auxs)
    @org = Factory(:organization)
    Factory(:organizational_permission, organization: @org, person: @user.person, permission: Permission.admin)
  end
  
  # context "label_name function" do
  #     should "return the default label name format" do
  #       stub_request(:put, "https://s3.amazonaws.com/staging.missionhub.com/mh/imports/uploads/342/sample_import_1.csv").
  #   with(:body => "first_name,last_name,email\nJono,Malobo,jonomalobo@email.com\n",
  #        :headers => {'Accept'=>'*/*', 'Authorization'=>'AWS 0MZHF18QSJRVZT04JXR2:ZWCUr0ed7MBledNqWrw0c//TRR4=', 'Content-Length'=>'58', 'Content-Type'=>'application/csv', 'Date'=>'Tue, 28 Aug 2012 19:11:03 +0800', 'User-Agent'=>'aws-sdk-ruby/1.6.4 ruby/1.9.3 x86_64-darwin12.0.0', 'X-Amz-Acl'=>'private', 'X-Amz-Storage-Class'=>'REDUCED_REDUNDANCY'}).to_return(:status => 200, :body => "", :headers => {})
  #         
  #       contacts_file = File.open(Rails.root.join("test/fixtures/contacts_upload_csv/sample_import_1.csv"))
  #       file = Rack::Test::UploadedFile.new(contacts_file, "application/csv")
  #       @import = Factory(:import, user: @user, organization: @org, upload: file)
  #       puts @import.inspect
  #     end
  # end
end
