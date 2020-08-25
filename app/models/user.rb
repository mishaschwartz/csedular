class User < ApplicationRecord
  has_many :bookings, dependent: :destroy
  has_many :availabilities, through: :bookings
  has_secure_token :api_key

  validates_uniqueness_of :username
  validates_presence_of :display_name
  validates_uniqueness_of :email, allow_nil: true

  after_update :delete_future_bookings

  scope :data, -> { pluck_to_hash(*DATA_FIELDS) }

  def active?
    self.admin || self.client
  end

  def hit_bookings_limit?
    self.bookings.future.count >= Rails.configuration.future_bookings
  end

  private

  DATA_FIELDS = %w[username display_name email id admin client read_only]

  def delete_future_bookings
    bookings.future.destroy_all if saved_change_to_client?(from: true, to: false)
  end
end
