class LocationPolicy < ApplicationPolicy
  def show?
    check?(:admin?) || check?(:client?)
  end

  def index?
    check?(:admin?)
  end
end