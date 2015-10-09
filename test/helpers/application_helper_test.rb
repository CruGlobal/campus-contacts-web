require 'test_helper'
require 'application_helper'

class ApplicationHelperTest < ActionView::TestCase
  include ApplicationHelper

  test 'uri' do
    assert uri?('http://google.com')
    assert uri?('https://facebook.com')
    assert !uri?('hahahahah')
  end

  test 'tip' do
    assert_equal "<span class=\"icon help tip help_bubble_keyword\" title=\"WAT\" style=\"float: none;\"></span>".html_safe, tip('WAT')
  end

  test 'spinner' do
    assert_equal "<img id=\"spinner\" style=\"display:none\" class=\"spinner\" src=\"/images/spinner.gif\" alt=\"Spinner\" />", spinner
  end

  test 'add params' do
    hash = {}
    hash['test1'] = 1
    hash['test2'] = 2

    assert_equal 'http://google.com?test1=1&test2=2', add_params('http://google.com', hash)

    hash2 = {}
    hash['test3'] = 3

    merge = {}
    merge['test1'] = 1
    merge['test2'] = 2
    merge['test3'] = 3
    assert_equal merge, add_params(hash2, hash)
  end
end
