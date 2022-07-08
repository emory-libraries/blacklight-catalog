# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user&.admin?

    can :index, :admin
    can :manage, :flipflop
  end
end
