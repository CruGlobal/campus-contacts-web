module V4
  class User < ActiveRecord::Base
    has_secure_token

    has_one :person, foreign_key: 'user_id'

    attr_accessible :username
  end
end
