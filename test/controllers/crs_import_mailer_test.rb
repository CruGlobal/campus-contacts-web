require 'test_helper'

class CrsImportMailerTest < ActionMailer::TestCase
  test "CRS Import Failed" do
    @org = FactoryGirl.create(:organization)
    mail = CrsImportMailer.failed(@org, 'crs@example.com')
    assert_equal "CRS Import Failed", mail.subject
    assert_equal ["crs@example.com"], mail.to
  end

  test "CRS Import Completed" do
    @org = FactoryGirl.create(:organization)
    mail = CrsImportMailer.completed(@org, 'crs@example.com')
    assert_equal "CRS Import Completed", mail.subject
    assert_equal ["crs@example.com"], mail.to
  end
end
