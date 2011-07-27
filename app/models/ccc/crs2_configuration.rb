class Ccc::Crs2Configuration < ActiveRecord::Base
  set_table_name 'crs2_configuration'
  belongs_to :crs2_url_base, class_name: 'Ccc::Crs2UrlBase', foreign_key: :default_url_base_id
end
