module ApiErrors 
  class ApiError < StandardError
    def initialize(code, message, number, title = nil)
      if title.nil?
        m = '{"error": {"message":"' + message + '", "code": "' + number  + '"}}'
      else
        m = '{"error": {"message":"' + message + '", "code": "' + number  + '", "title":"' + title + '"}}'
      super m
      @code = code.to_sym
      end
    end

    attr_reader :code
  end

  class InvalidFieldError < ApiError
    def initialize 
      super :invalid_fields, "One or more of the specified fields does not exist.", "21", "API Error"
    end
  end
  class InvalidRequest < ApiError
    def initialize
      super :invalid_request, "Your API request URL is invalid.", "22", "API Error"
    end
  end
  class NoDataReturned < ApiError
    def initialize
      super :no_data_returned, "Your API request did not return any data.", "23", "Message"
    end
  end
  class OrgNotAllowedError < ApiError
    def initialize
      super :org_not_allowed, "You do not have the appropriate organization memberships to view this data.", "24", "Message"
    end
  end
  class IncorrectPermissionsError < ApiError
    def initialize
      super :incorrect_permissions, "You currently do not have leader permissions in MissionHub. Contact your local MissionHub administrator.", "25", "Permissions Required"
    end
  end
  class ContactAssignmentDeleteParamsError < ApiError
    def initialize
      super :contact_assignment_delete_params_error, "You did not provide the appropriate parameters to remove a contact assignment.", "26", "API Error"
    end
  end  
  class ContactAssignmentCreateParamsError < ApiError
    def initialize
      super :contact_assignment_create_params_error, "You did not provide the appropriate parameters to create a contact assignment.", "27", "API Error"
    end
  end
  class FollowupCommentCreateParamsError < ApiError
    def initialize
      super :followup_comment_create_params_error, "You did not provide the appropriate parameters to create a followup comment.", "28", "API Error"
    end
  end
  class FollowupCommentDeleteParamsError < ApiError
    def initialize
      super :followup_comment_delete_params_error, "You did not provide the appropriate parameters to remove a comment.", "34", "API Error"
    end
  end
  class LimitRequiredWithStartError < ApiError
    def initialize
      super :limit_required_with_start_error, "A limit parameter is required with a start parameter.", "29", "API Error"
    end
  end
  class OrganizationNotIntegerError < ApiError
    def initialize
      super :organization_not_integer_error, "Your given org or org_id parameter is not an integer.", "30", "API Error"
    end
  end
  class KeywordNotIntegerError < ApiError
    def initialize
      super :keyword_not_integer_error, "Your given keyword_id is not an integer.", "31", "API Error"
    end
  end
  class NoOrganizationError < ApiError
    def initialize
      # super :no_organization_error, "We could not find your organization.", "32", "Message"
      super :no_organization_error, "You need to go to www.MissionHub.com to setup your account in order use the MissionHub application.","32", "Message"
    end
  end
  class InvalidJSONError < ApiError
    def initialize
      super :invalid_json_error, "You did not send valid JSON.","33", "API Error"
    end
  end
  class FollowupCommentPermissionsError < ApiError
    def initialize
      super :followup_comments_permissions_error, "You do not have the appropriate permissions to delete this comment.","35", "Message"
    end
  end
  class AccountSetupRequiredError < ApiError
    def initialize
      super :account_setup_error, "You need to go to www.MissionHub.com to setup your account in order use the MissionHub application.","36", "Message"
    end
  end
  class InvalidRolesParamaters < ApiError
    def initialize
      super :invalid_roles_parameters, "You did not provide the appropriate parameters to change a person's role.", "37", "API Error"
    end
  end
  class NoRoleChangeMade < ApiError
    def initialize
      super :no_role_change_made, "No role change was made. Try again.", "38", "Message"
    end
  end
  class RolesPermissionsError < ApiError
    def initialize
      super :roles_permissions_error, "You do not have the appropriate permissions to change roles.","39", "Message"
    end
  end
end