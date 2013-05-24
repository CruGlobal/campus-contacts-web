class Ability
  include CanCan::Ability

  def initialize(user)
    #if user.developer?
      #can :all, :all
    #else
      roles = Role.default.all
      mh_user_role = roles.detect {|r| r.i18n == 'missionhub_user'}
      admin_role = roles.detect {|r| r.i18n == 'admin'}
      user ||= User.new # guest user (not logged in)
      if user && user.person
        admin_of_org_ids = user.person.admin_of_org_ids
        #user.person.organizations.where('organizational_roles.role_id' => admin_role.id).collect {|org| org.subtree_ids}.flatten
        mh_user_of_org_ids = user.person.mh_user_of_org_ids
        #user.person.organizations.where('organizational_roles.role_id' => Role.mh_user_ids).collect {|org| org.subtree_ids}.flatten

        can :manage, Organization, id: admin_of_org_ids
        can :lead, Organization, id: mh_user_of_org_ids

        can :manage_contacts, Organization, id: mh_user_of_org_ids
        
        can :manage_groups, Organization, id: mh_user_of_org_ids + admin_of_org_ids
        can :manage_locate_contact, Organization, id: mh_user_of_org_ids + admin_of_org_ids
        can :manage_roles, Organization, id: admin_of_org_ids

        # can only manage keywords from orgs you're an admin of
        can :manage, SmsKeyword, organization_id: admin_of_org_ids
        can :manage, Survey, organization_id: admin_of_org_ids
        can :manage, QuestionSheet, organization_id: admin_of_org_ids

        # Gotta be an admin somewhere to see keyword options
        unless admin_of_org_ids.present?
          cannot :manage, SmsKeyword
          cannot :manage, Survey
          cannot :manage, QuestionSheet
        else
          can :create, SmsKeyword
          can :create, Survey
          can :create, QuestionSheet
        end

        # involved members can see other people's info
        involved_org_ids = user.person.organizational_roles.where(role_id: [admin_role.id, mh_user_role.id]).pluck(:organization_id)
        can :read, Person, organizational_roles_including_archived: {organization_id: involved_org_ids}
        can :read, PersonPresenter, organizational_roles: { organization_id: involved_org_ids }

        # mh_users and admins can edit other ppl's info
        if user.person.admin_or_mh_user?
          can :create, SmsMailer
          can :create, Person
          can :create, PersonPresenter
          can :manage, Person, organizational_roles_including_archived: {organization_id: mh_user_of_org_ids}
          can :manage, PersonPresenter, organizational_roles_including_archived: {organization_id: mh_user_of_org_ids}
        end

        can :manage, Person, id: user.person.try(:id)
        can :manage, PersonPresenter, id: user.person.try(:id)

        can :manage, Group, organization_id: mh_user_of_org_ids
        can :manage, GroupPresenter, organization_id: mh_user_of_org_ids
      #end

    end
    #
    # The first argument to `can` is the action you are giving the user permission to do.
    # If you pass :manage it will apply to every action. Other common actions here are
    # :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. If you pass
    # :all it will apply to every resource. Otherwise pass a Ruby class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, published: true
    #
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end
