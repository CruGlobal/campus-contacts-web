class SmsKeyword < ActiveRecord::Base
  def self.default
    new(:name => 'Cru', :keyword => 'cru')
  end
end
