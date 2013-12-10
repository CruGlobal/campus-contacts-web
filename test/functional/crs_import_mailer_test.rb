require 'test_helper'

class CrsImportMailerTest < ActionMailer::TestCase
  test "CRS Import Failed" do
    @org = Factory(:organization)
    mail = CrsImportMailer.failed(@org, 'crs@example.com')
    assert_equal "Crs Import Failed", mail.subject
    assert_equal ["crs@example.com"], mail.to
  end

  test "CRS Import Completed" do
    @org = Factory(:organization)
    mail = CrsImportMailer.completed(@org, 'crs@example.com')
    assert_equal "Crs Import Completed", mail.subject
    assert_equal ["crs@example.com"], mail.to
  end
end
