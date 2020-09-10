class BookingPolicy < ApplicationPolicy
  def destroy?
    !check?(:read_only?) && (
      check?(:admin?) || (
        check?(:client?) && check?(:record_owner?) && record&.can_cancel?
      )
    )
  end

  def index?
    check?(:admin?) || check?(:client?)
  end

  def create?
    !check?(:read_only?) && (
      check?(:admin?) || (
        check?(:client?) && !user.hit_bookings_limit?
      )
    )
  end

  def help?
    true
  end
end