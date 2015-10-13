module V4
  class User < ActiveRecord::Base
    has_secure_token

    attr_accessible :username
  end
end
