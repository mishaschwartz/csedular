class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :availability
  belongs_to :creator, class_name: 'User'
  has_one :resource, through: :availability
  has_one :location, through: :resource

  validate :belongs_to_client
  validate :enforce_limit, on: :create

  scope :future, -> { where(availability_id: Availability.future.ids) }
  scope :past, -> { where(availability_id: Availability.past.ids) }
  scope :current, -> { where(availability_id: Availability.current.ids) }

  def can_cancel?
    Availability.booked.cancelable.ids.include? self.availability_id
  end

  private

  def enforce_limit
    return if user.nil? || creator&.admin

    errors.add(:base, :future_bookings, limit: Rails.configuration.future_bookings) if user.hit_bookings_limit?
  end

  def belongs_to_client
    return if user.nil? || availability&.start_time&.<(Time.current)
    errors.add(:base, :user_not_client) unless user.client
  end
end
