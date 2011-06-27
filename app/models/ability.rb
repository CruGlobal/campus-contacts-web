class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    if user && user.person
      # leaders and admins can edit other ppl's info
      can :manage, Person, organizations: {id: user.person.organization_memberships.where(role: ['leader','admin']).collect(&:organization_id)}
      
      # can only manage keywords from orgs you're an admin of
      can :manage, SmsKeyword, organization_id: user.person.organization_memberships.where(role: 'admin').collect(&:organization_id)
      # Gotta be an admin somewhere to see keyword options
      unless user.person.organization_memberships.where(role: 'admin').present?
        cannot :manage, SmsKeyword
      end
      
      # involved members can see other people's info
      can :read, Person, organizations: {id: user.person.organization_memberships.where(role: 'involved').collect(&:organization_id)}
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
