class Ccc::SchemaMigration < ActiveRecord::Base
  self.primary_key = 'version'
  
end
