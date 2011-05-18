module ApiErrors 
  class ApiError < StandardError
    def initialize(code, message)
      super message
      @code = code.to_sym
    end

    attr_reader :code
  end

  class IncorrectScopeError < ApiError
    def initialize
      super :incorrect_scope, "You do not have sufficient scope to access this information."
    end
  end

  class InvalidScopeError < ApiError
    def initialize
      super :invalid_scope, "One or more of the specified scopes does not exist."
    end
  end

  class InvalidFieldError < ApiError
    def initialize 
      super :invalid_fields, "One or more of the specified fields does not exist."
    end
  end

  class InvalidRequest < ApiError
    def initialize
      super :invalid_request, "Your API request URL is invalid."
    end
  end
end