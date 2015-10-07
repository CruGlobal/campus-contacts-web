#encoding: utf-8
module V4
  class Person < ActiveRecord::Base
    belongs_to :user
  end
end
