describe Resource do
  subject { build :resource }
  it { is_expected.to belong_to(:location) }
  it { is_expected.to have_many(:availabilities).dependent(:destroy) }
  it { is_expected.to have_many(:bookings).through(:availabilities) }
  it { is_expected.to validate_presence_of(:resource_type) }
  it { is_expected.to validate_uniqueness_of(:name).scoped_to(:location_id) }
end
