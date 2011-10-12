class WelcomeController < ApplicationController
  skip_before_filter :authenticate_user!, only: [:index, :tour, :terms, :privacy]
  skip_before_filter :check_url, only: [:terms, :privacy]
  def index
    # if user_signed_in?
    #   redirect_to user_root_path and return
    # end
    render layout: 'splash'#, stream: true
  end
  
  def wizard
    session[:wizard] = nil
    case params[:step]
    when 'keyword'
      @redirect = true unless current_organization
    when 'survey'
      @redirect = true unless current_organization && current_organization.self_and_children_keywords.present?
    when 'leaders'
      @redirect = true unless current_organization
    end
    if @redirect
      redirect_to wizard_path and return
    end
  end
  
  def verify_with_relay
    if params[:ticket]
      if RubyCAS::Filter.filter(self)
        guid = get_guid_from_ticket(session[:cas_last_valid_ticket])
        # See if we have a user with this guid
        user = User.find_by_globallyUniqueID(guid)
        if user && current_user != user
          sign_out(current_user)
          old_user = User.find(current_user.id)
          user.merge(old_user)
          user.reload
          sign_in(user)
        end
        if user && user.person && user.person.organizations.present? && user.person.organizations.any? {|org| user.person.leader_in?(org)}
          redirect_to wizard_path ? wizard_path : user_root_path
        else
          redirect_to '/wizard?step=verify&not_found=1'
        end
      end
    else
      redirect_to('https://signin.ccci.org/cas/login?service=' + verify_with_relay_url)
      return
    end
  end
  def tour
    render layout: 'splash'
  end
  
  def terms
    render layout: mhub? ? 'mhub' : 'splash'
  end
  
  def privacy
    render layout: mhub? ? 'mhub' : 'splash'
  end
end
