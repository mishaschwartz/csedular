describe Booking do
  subject { build(:booking) }
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:availability) }
  it { is_expected.to belong_to(:creator) }
  it { is_expected.to have_one(:resource).through(:availability) }
  it { is_expected.to have_one(:location).through(:resource) }
  it 'should belong to a client' do
    expect(build(:booking, user: build(:client))).to be_valid
  end
  it 'should not belong to a non-client' do
    expect(build(:future_booking, user: build(:user, client: false))).not_to be_valid
  end
  it 'can belong to a non-client if it is in the past' do
    expect(build(:booking, user: build(:user, client: false))).to be_valid
  end
  context 'enforcing the booking limit' do
    let(:user) { create :client }
    let(:availability) { build(:availability, start_time: 10.days.from_now, end_time: 11.days.from_now) }
    before do
      create(:future_booking, user: user)
      allow(Rails.configuration).to receive(:future_bookings).and_return(1)
    end
    context 'the creator is an admin' do
      let(:creator) { create :admin }
      it 'should not enforce the future bookings limit' do
        expect(build(:future_booking, creator: creator, user: user, availability: availability)).to be_valid
      end
    end
    context 'the creator is not an admin' do
      let(:creator) { create :client }
      it 'should enforce the future bookings limit' do
        expect(build(:future_booking, creator: creator, user: user, availability: availability)).not_to be_valid
      end
    end
  end
  it 'should allow non-overlapping availabilities for the same user' do
    user = create(:client)
    create(:booking, user: user, availability: build(:availability, start_time: Time.now, end_time: Time.now + 1.hour))
    avail = build(:availability, start_time: Time.now + 2.hours, end_time: Time.now + 3.hours)
    expect(build(:booking, user: user, availability: avail)).to be_valid
  end
  it 'should not allow overlapping availabilities for the same user' do
    user = create(:client)
    create(:booking, user: user, availability: build(:availability, start_time: Time.now, end_time: Time.now + 1.hour))
    avail = build(:availability, start_time: Time.now + 30.minutes, end_time: Time.now + 2.hours)
    expect(build(:booking, user: user, availability: avail)).to be_valid
  end
  it 'should allow overlapping availabilities for different user' do
    create(:booking, availability: build(:availability, start_time: Time.now, end_time: Time.now + 1.hour))
    avail = build(:availability, start_time: Time.now + 30.minutes, end_time: Time.now + 2.hours)
    expect(build(:booking, availability: avail)).to be_valid
  end

  describe '#can_cancel?' do
    let(:booking) { create(:booking, availability: availability) }
    before { allow(Rails.configuration).to receive(:cancelation_blackout).and_return(1.hour) }
    context 'when the booking has started' do
      let(:availability) { build(:availability, start_time: 1.hour.ago, end_time: 2.hours.from_now) }
      it 'should be false' do
        expect(booking.can_cancel?).to be false
      end
    end
    context 'when the booking start time is in the cancellation blackout period' do
      let(:availability) { build(:availability, start_time: 10.minutes.from_now, end_time: 2.hours.from_now) }
      it 'should be false' do
        expect(booking.can_cancel?).to be false
      end
    end
    context 'when the booking start time is after the cancellation blackout period' do
      let(:availability) { build(:availability, start_time: 2.hours.from_now, end_time: 3.hours.from_now) }
      it 'should be true' do
        expect(booking.can_cancel?).to be true
      end
    end
  end
end
