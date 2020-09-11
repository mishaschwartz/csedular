class Availability < ApplicationRecord
  belongs_to :resource
  has_one :booking, dependent: :destroy

  validates_presence_of :start_time
  validates_presence_of :end_time
  validate :start_before_end
  validate :no_overlapping

  default_scope { order(:start_time) }
  scope :free, -> { left_outer_joins(:booking).where('bookings.id': nil) }
  scope :booked, -> { where.not(id: free) }
  scope :future, -> { where(start_time: Time.current..DateTime::Infinity.new ) }
  scope :past, -> { where(end_time: Time.new(0)..Time.current ) }
  scope :current, -> { where.not(id: future).where.not(id: past) }
  scope :bookable, -> {
    where(id: free).where(end_time: (Time.current + Rails.configuration.booking_blackout)..DateTime::Infinity.new )
  }
  scope :cancelable, -> {
    where('start_time': (Time.current + Rails.configuration.cancelation_blackout)..DateTime::Infinity.new )
  }
  scope :data, -> { left_outer_joins(booking: :user, resource: :location).pluck_to_hash(*DATA_FIELDS) }

  private

  DATA_FIELDS = ['availabilities.start_time as start_time',
                 'availabilities.end_time as end_time',
                 'availabilities.id as availability_id',
                 'resources.id as resource_id',
                 'resources.name as resource_name',
                 'resources.resource_type as resource_type',
                 'locations.name as location_name',
                 'locations.id as location_id',
                 'users.id as user_id',
                 'users.username as username',
                 'bookings.id as booking_id',
                 'bookings.created_at as booking_created_time'].freeze

  def start_before_end
    return if self.start_time.nil? || self.end_time.nil?
    self.errors.add(:base, :start_before_end) unless self.start_time < self.end_time
  end

  def no_overlapping
    return if self.resource.nil? || self.start_time.nil? || self.end_time.nil?

    times = self.resource
                .availabilities
                .where.not(id: self.id)
                .pluck(:start_time, :end_time) + [[self.start_time, self.end_time]]
    times = times.sort.flatten
    self.errors.add(:base, :overlapping_availabilities) if times != times.sort
  end
end
