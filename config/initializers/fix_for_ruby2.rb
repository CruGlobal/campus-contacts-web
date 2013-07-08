module ActiveModel
  class Errors
    public :initialize_dup
  end

  module Validations
    public :initialize_dup
  end
end

class ActiveRecord::Base
  public :initialize_dup
end