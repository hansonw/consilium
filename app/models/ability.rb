class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    if user.permissions > User::CLIENT
      if user.permissions == User::ADMIN
        can :manage, Brokerage, :id => user.brokerage.id
        can :manage, User, :brokerage_id => user.brokerage.id
      else
        can :read, Brokerage, :id => user.brokerage.id
        can :manage, User, :id => user.id
        can :read, User, :brokerage_id => user.brokerage.id
        cannot :manage, User
      end

      can :manage, Client, :brokerage_id => user.brokerage.id
      can :create, Client

      can :manage, Document do |document|
        document.client.brokerage == user.brokerage
      end
      can :create, Document
    else
      can :manage, Client do |client|
        perm = UserPermission.where(:user => user, :client => client).first
        perm && perm.can_manage
      end
      cannot :manage, Client
    end

    can :manage, RecentClients, :user => user
    can :create, RecentClients

    # Tied directly to the Client.
    can :manage, ClientChange do |change|
      can? :manage, change.client
    end
  end

  def select(collection)
    collection.select { |c| can? :read, c }
  end
end
