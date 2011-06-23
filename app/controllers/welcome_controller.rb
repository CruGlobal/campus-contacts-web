class WelcomeController < ApplicationController
  skip_before_filter :authenticate_user!, :only => :index
  def index
    if user_signed_in?
      redirect_to user_root_path and return
    end
    render :layout => 'splash', :stream => true
  end
  
  def wizard
    session[:wizard] = nil
    case params[:step]
    when 'keyword'
      @redirect = true unless current_organization
    when 'survey'
      @redirect = true unless current_organization && current_organization.keywords.present?
    when 'leaders'
      @redirect = true unless current_organization
    end
    if @redirect
      redirect_to '/wizard?step=' + current_user.next_wizard_step(current_organization) and return
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
          sign_in(user)
        end
        if user && user.person.organizations.present? && user.person.organizations.any? {|org| user.person.leader_in?(org)}
          redirect_to '/wizard?step=keyword'
        else
          redirect_to '/wizard?step=verify&not_found=1'
        end
      end
    else
      redirect_to('https://signin.ccci.org/cas/login?service=' + verify_with_relay_url)
      return
    end
  end
end
