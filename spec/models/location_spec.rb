describe Location do
  subject { build :location }
  it { is_expected.to have_many(:resources).dependent(:destroy) }
  it { is_expected.to validate_uniqueness_of(:name) }
end
