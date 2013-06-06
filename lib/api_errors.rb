module ApiErrors 
  class ApiError < StandardError
    def initialize(message, number = nil, title = nil)
      @mess = message
      @number = number
      @title = title  
      if title.nil?
        m = '{"error": {"message":"' + message + '", "code": "' + number  + '"}}'
      else
        m = '{"error": {"message":"' + message + '", "code": "' + number  + '", "title":"' + title + '"}}'
        super m
      end
    end

    def to_hash
      error = {}
      error[:message] = @mess unless @mess.nil?
      error[:code] = @number unless @number.nil?
      error[:title] = @title unless @title.nil?
      error
    end

  end

  class InvalidFieldError < ApiError
    def initialize 
      super "One or more of the specified fields does not exist.", "21", "API Error"
    end
  end
  class InvalidRequest < ApiError
    def initialize
      super "Your API request URL is invalid.", "22", "API Error"
    end
  end
  class NoDataReturned < ApiError
    def initialize
      super "Your API request did not return any data.", "23", "Message"
    end
  end
  class OrgNotAllowedError < ApiError
    def initialize
      super "You do not have the appropriate organization memberships to view this data.", "24", "Message"
    end
  end
  class IncorrectPermissionsError < ApiError
    def initialize
      super "You currently do not have leader permissions in MissionHub. Contact your local MissionHub administrator.", "25", "Permissions Required"
    end
  end
  class ContactAssignmentDeleteParamsError < ApiError
    def initialize
      super "You did not provide the appropriate parameters to remove a contact assignment.", "26", "API Error"
    end
  end  
  class ContactAssignmentCreateParamsError < ApiError
    def initialize
      super "You did not provide the appropriate parameters to create a contact assignment.", "27", "API Error"
    end
  end
  class FollowupCommentCreateParamsError < ApiError
    def initialize
      super "You did not provide the appropriate parameters to create a followup comment.", "28", "API Error"
    end
  end
  class FollowupCommentDeleteParamsError < ApiError
    def initialize
      super "You did not provide the appropriate parameters to remove a comment.", "34", "API Error"
    end
  end
  class LimitRequiredWithStartError < ApiError
    def initialize
      super "A limit parameter is required with a start parameter.", "29", "API Error"
    end
  end
  class OrganizationNotIntegerError < ApiError
    def initialize
      super "Your given org or org_id parameter is not an integer.", "30", "API Error"
    end
  end
  class KeywordNotIntegerError < ApiError
    def initialize
      super "Your given keyword_id is not an integer.", "31", "API Error"
    end
  end
  class NoOrganizationError < ApiError
    def initialize
      # super "We could not find your organization.", "32", "Message"
      super "You need to go to www.MissionHub.com to setup your account in order use the MissionHub application.","32", "Message"
    end
  end
  class InvalidJSONError < ApiError
    def initialize
      super "You did not send valid JSON.","33", "API Error"
    end
  end
  class FollowupCommentPermissionsError < ApiError
    def initialize
      super "You do not have the appropriate permissions to delete this comment.","35", "Message"
    end
  end
  class AccountSetupRequiredError < ApiError
    def initialize
      super "You need to go to www.MissionHub.com to setup your account in order use the MissionHub application.","36", "Message"
    end
  end
  class InvalidPermissionsParamaters < ApiError
    def initialize
      super "You did not provide the appropriate parameters to change a person's permission.", "37", "API Error"
    end
  end
  class NoPermissionChangeMade < ApiError
    def initialize
      super "No role change was made. Try again.", "38", "Message"
    end
  end
  class PermissionsError < ApiError
    def initialize
      super "You do not have the appropriate permissions to change roles.","39", "Message"
    end
  end
  class ContactAssignmentStateError < ApiError
    def initialize
      super "The contact was no longer assigned to the expected person or organization.", "40", "API Error"
    end
  end
  class MissingData < ApiError
    def initialize(message = nil)
      super message, "41", "API Error"
    end
  end
  class InteractionPermissionsError < ApiError
    def initialize
      super "You do not have the appropriate permissions to delete this interaction.","43", "Message"
    end
  end
  class InteractionCreateParamsError < ApiError
    def initialize
      super "You did not provide the appropriate parameters to create an interaction.", "44", "API Error"
    end
  end
  class InteractionDeleteParamsError < ApiError
    def initialize
      super "You did not provide the appropriate parameters to remove an interaction.", "45", "API Error"
    end
  end
end