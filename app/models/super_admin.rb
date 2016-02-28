class SuperAdmin < ActiveRecord::Base
  belongs_to :user

  default_value_for :site, ENV['SITE_TITLE']
end
