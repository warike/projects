class Ability
  include CanCan::Ability

  def initialize(user)

    user ||= User.new #si no hay user creo un guest

    
    if user.role == "admin"
        can :manage, :all
    elsif user.role == "author"
        can :manage, :all
    else    
        can [:published, :new, :show, :index], Startup

    end

    # user ||= User.new # guest user (not logged in)
    #  if user.admin?
    #     can :manage, :all
    #  elsif user.author?   
    #     can :edit, Startup, :user_id => current_user.id
    #  else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
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
  end
end
