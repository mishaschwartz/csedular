class AvailabilityPolicy < ApplicationPolicy
  def index?
    check?(:admin?)
  end

  def show?
    check?(:admin?)
  end

  def all?
    check?(:admin?)
  end
end
