describe Availability do
  subject { build(:availability) }
  it { is_expected.to belong_to(:resource) }
  it { is_expected.to have_one(:booking).dependent(:destroy) }
  it { is_expected.to validate_presence_of(:start_time) }
  it { is_expected.to validate_presence_of(:end_time) }
  it 'should not start after it ends' do
    expect(build(:availability, start_time: Time.now, end_time: Time.now - 1.hour)).not_to be_valid
  end
  it 'should start before it ends' do
    expect(build(:availability, start_time: Time.now, end_time: Time.now + 1.hour)).to be_valid
  end
  it 'should allow non-overlapping availabilities for the same resource' do
    resource = create(:resource)
    create(:availability, start_time: Time.now, end_time: Time.now + 1.hour, resource: resource)
    new = build(:availability, start_time: Time.now + 2.hours, end_time: Time.now + 3.hours, resource: resource)
    expect(new).to be_valid
  end
  it 'should not allow overlapping availabilities for the same resource' do
    resource = create(:resource)
    create(:availability, start_time: Time.now, end_time: Time.now + 1.hour, resource: resource)
    new = build(:availability, start_time: Time.now + 30.minutes, end_time: Time.now + 2.hours, resource: resource)
    expect(new).not_to be_valid
  end
  it 'should allow overlapping availabilities for different resources' do
    create(:availability, start_time: Time.now, end_time: Time.now + 1.hour)
    new = build(:availability, start_time: Time.now + 30.minutes, end_time: Time.now + 1.hours)
    expect(new).to be_valid
  end
end
