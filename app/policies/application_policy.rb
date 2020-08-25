# Base class for application policies
class ApplicationPolicy < ActionPolicy::Base
  def admin?
    user.admin
  end

  def client?
    user.client
  end

  def read_only?
    user.read_only
  end

  def new?
    check?(:admin?) && !check?(:read_only?)
  end

  def create?
    check?(:admin?) && !check?(:read_only?)
  end

  def update?
    check?(:admin?) && !check?(:read_only?)
  end

  def edit?
    check?(:admin?) && !check?(:read_only?)
  end

  def destroy?
    check?(:admin?) && !check?(:read_only?)
  end

  def record_owner?
    record&.user_id == user.id
  end

  def see_booking_button?
    !check?(:read_only?) && (check?(:admin?) || (check?(:client?) && !user.hit_bookings_limit?))
  end

  def see_cancel_button?
    !check?(:read_only?) && (check?(:admin?) || check?(:client?))
  end

  def access_api?
    check?(:admin?)
  end
end
