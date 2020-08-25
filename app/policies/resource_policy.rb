class ResourcePolicy < ApplicationPolicy
  def index?
    check?(:admin?)
  end

  def show?
    check?(:admin?) || check?(:client?)
  end

  def create_availability?
    check?(:admin?) && !check?(:read_only?)
  end

  def destroy_availability?
    check?(:admin?) && !check?(:read_only?)
  end

  def current?
    check?(:admin?)
  end
end