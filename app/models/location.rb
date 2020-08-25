class Location < ApplicationRecord
  has_many :resources, dependent: :destroy

  validates_uniqueness_of :name
end
