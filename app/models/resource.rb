class Resource < ApplicationRecord
  belongs_to :location
  has_many :availabilities, dependent: :destroy
  has_many :bookings, through: :availabilities

  validates_presence_of :resource_type
  validates_uniqueness_of :name, scope: :location_id
end
