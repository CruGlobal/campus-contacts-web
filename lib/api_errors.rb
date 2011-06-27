module ApiErrors 
  class ApiError < StandardError
    def initialize(code, message, number)
      super '{"error": {"message":"' + message + '", "code": "' + number  + '"}}'
      @code = code.to_sym
    end

    attr_reader :code
  end

  # class IncorrectScopeError < ApiError
  #   def initialize
  #     super :incorrect_scope, "You do not have sufficient scope to access this information.", 
  #   end
  # end
  # 
  # class InvalidScopeError < ApiError
  #   def initialize
  #     super :invalid_scope, "One or more of the specified scopes does not exist."
  #   end
  # end

  class InvalidFieldError < ApiError
    def initialize 
      super :invalid_fields, "One or more of the specified fields does not exist.", "21"
    end
  end

  class InvalidRequest < ApiError
    def initialize
      super :invalid_request, "Your API request URL is invalid.", "22"
    end
  end

  class NoDataReturned < ApiError
    def initialize
      super :no_data_returned, "Your API request did not return any data.", "23"
    end
  end
  class OrgNotAllowedError < ApiError
    def initialize
      super :org_not_allowed, "You do not have the appropriate organization memberships to view this data.", "24"
    end
  end
  class IncorrectPermissionsError < ApiError
    def initialize
      super :incorrect_permissions, "You do not have the appropriate permissions to view this data.", "25"
    end
  end
  class ContactAssignmentDeleteParamsError < ApiError
    def initialize
      super :contact_assignment_delete_params_error, "You did not provide the appropriate parameters to remove a contact assignment.", "26"
    end
  end  
  class ContactAssignmentCreateParamsError < ApiError
    def initialize
      super :contact_assignment_create_params_error, "You did not provide the appropriate parameters to create a contact assignment.", "27"
    end
  end
  class FollowupCommentCreateParamsError < ApiError
    def initialize
      super :followup_comment_create_params_error, "You did not provide the appropriate parameters to create a followup comment.", "28"
    end
  end
  class FollowupCommentDeleteParamsError < ApiError
    def initialize
      super :followup_comment_delete_params_error, "You did not provide the appropriate parameters to remove a comment.", "34"
    end
  end
  class LimitRequiredWithStartError < ApiError
    def initialize
      super :limit_required_with_start_error, "A limit parameter is required with a start parameter.", "29"
    end
  end
  class OrganizationNotIntegerError < ApiError
    def initialize
      super :organization_not_integer_error, "Your given org or org_id parameter is not an integer.", "30"
    end
  end
  class KeywordNotIntegerError < ApiError
    def initialize
      super :keyword_not_integer_error, "Your given keyword_id is not an integer.", "31"
    end
  end
  class NoOrganizationError < ApiError
    def initialize
      super :no_organization_error, "We could not find your organization.  Specify org_id as a query parameter.", "32"
    end
  end
  
  class InvalidJSONError < ApiError
    def initialize
      super :invalid_json_error, "You did not send valid JSON.","33"
    end
  end
  class FollowupCommentPermissionsError < ApiError
    def initialize
      super :followup_comments_permissions_error, "You do not have the appropriate permissions to delete this comment.","35"
    end
  end
  
  
end