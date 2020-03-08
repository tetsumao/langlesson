# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    if user.admin?
      can :manage, :all
    elsif user.teacher?
      can [:show, :update], :teacher
      can :manage, Lesson
      cannot [:search, :reserve, :reserved], Lesson
    else
      can :show, :teacher
      can [:show, :search, :reserve, :reserved], Lesson
      can :manage, Ticket
      can :manage, :payment
    end
  end
end
