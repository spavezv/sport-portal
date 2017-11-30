class Ability
  include CanCan::Ability
  # The first argument to `can` is the action you are giving the user
  # permission to do.
  # If you pass :manage it will apply to every action. Other common actions
  # here are :read, :create, :update and :destroy.
  # You will usually be working with these four actions.
  # These aren't the same as the 7 RESTful actions in Rails!
  # CanCanCan automatically adds some convenient aliases for mapping the controller actions.
  # https://github.com/CanCanCommunity/cancancan/wiki/Action-Aliases
  #  `alias_action :index, :show, :to => :read`
  #  `alias_action :new, :to => :create`
  #  `alias_action :edit, :to => :update`
  #
  # The second argument is the resource the user can perform the action on.
  # If you pass :all it will apply to every resource. Otherwise pass a Ruby
  # class of the resource.
  #
  # The third argument is an optional hash of conditions to further filter the
  # objects.
  # For example, here the user can only update published articles.
  #
  #   can :update, Article, :published => true
  #
  # See the wiki for details:
  # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities

  def initialize(user, team_member = nil)
    can :read, :all
    cannot :read, Team, private: true

    if user.present?
      user_id = user.id

      can :manage, User, id: user_id

      can :join, Event
      can :manage, Event, owner_id: user_id

      can :create, :all

      can_crud_team(user_id)

      can_assign_ownership(user)

      can_delete_ownership(user)

      can_delete_membership(team_member, user)

      cannot :create, User

      if user.admin?
        can :manage, :all
      end
    end
  end

  private

    def can_crud_team(user_id)
      can :read, Team, private: true, members: { id: user_id }
      can :update, Team, members: { id: user_id }
      can :destroy, Team, owners: { id: user_id }
    end

    def can_assign_ownership(user)
      can :assign_ownership, Team, Team do |team|
        team.owners.include? user
      end
    end

    def can_delete_membership(team_member, user)
      can :delete_membership, Team, Team do |team|
        user_id = user.id
        exist_owners_after_delete = owners_after_delete = Ability.number_of_owners_after_delete(team, team_member) > 0
        ((team.owners.include? user) && exist_owners_after_delete) || ((user_id == Integer(team_member)) && exist_owners_after_delete)
      end
    end

    def can_delete_ownership(user)
      can :delete_ownership, Team, Team do |team|
        (team.owners.include? user) && team.has_multiple_owners?
      end
    end

    def self.number_of_owners_after_delete(team, team_member)
      owners = team.owners
      another_user = User.find(team_member)
      if owners.include? another_user
        owners_after_delete = owners - [another_user]
      else
        owners_after_delete = owners
      end
      owners_after_delete.length
    end
end
