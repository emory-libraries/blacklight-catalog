# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user&.admin?

    can :manage, :admin
    can :manage, :flipflop
    can :read, ContentBlock
    can :update, ContentBlock
  end
end
