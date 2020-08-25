class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :availability
  belongs_to :creator, class_name: 'User'
  has_one :resource, through: :availability
  has_one :location, through: :resource

  validate :belongs_to_client
  validate :enforce_limit, on: :create
  validate :no_overlapping_for_user

  scope :future, -> {
    joins(:availability).where('availabilities.start_time': Time.current..DateTime::Infinity.new)
  }

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

  def no_overlapping_for_user
    return if user.nil? || availability.nil?

    times = self.user
                .bookings
                .joins(:availability)
                .where.not(id: self.id)
                .pluck(:start_time, :end_time) + [[self.availability.start_time, self.availability.end_time]]
    times = times.sort.flatten

    self.errors.add(:base, :overlapping_bookings) if times != times.sort
  end
end
