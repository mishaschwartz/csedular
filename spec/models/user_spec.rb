describe User do
  subject { build :user }
  it { is_expected.to have_many(:bookings).dependent(:destroy) }
  it { is_expected.to have_many(:availabilities).through(:bookings) }
  it { is_expected.to have_secure_token(:api_key) }
  it { is_expected.to validate_uniqueness_of(:username) }
  it { is_expected.to validate_presence_of(:display_name) }
  it { is_expected.to validate_uniqueness_of(:email).allow_nil }
  context 'update future bookings on update' do
    let(:user) { create :client }
    let!(:future_booking) { create :future_booking, user: user }
    let!(:current_booking) { create :booking, user: user }
    context 'when the user is no longer a client' do
      before { user.update(client: false) }
      it 'should delete future bookings' do
        expect { future_booking.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
      it 'should not delete current bookings' do
        expect { current_booking.reload }.not_to raise_error
      end
    end
    context 'when the user remains a client' do
      before { user.update(admin: true) }
      it 'should not delete future bookings' do
        expect { future_booking.reload }.not_to raise_error
      end
      it 'should not delete current bookings' do
        expect { current_booking.reload }.not_to raise_error
      end
    end
  end

  describe '#active?' do
    it 'should return true for an admin' do
      expect(build(:admin).active?).to be true
    end
    it 'should return true for a client' do
      expect(build(:client).active?).to be true
    end
    it 'should return false for a non-admin/non-client' do
      expect(build(:user).active?).to be false
    end
  end

  describe '#hit_bookings_limit?' do
    let(:user) { build :client }
    before do
      allow(Rails.configuration).to receive(:future_bookings).and_return(5)
      count.times.each do |i|
        start = (i+1).hours.from_now
        end_ = start + 30.minutes
        create(:booking, user: user, availability: build(:availability, start_time: start, end_time: end_))
      end
      allow(Rails.configuration).to receive(:future_bookings).and_return(3)
    end
    context 'under the limit' do
      let(:count) { 2 }
      it 'should return false' do
        expect(user.hit_bookings_limit?).to be false
      end
    end
    context 'at the limit' do
      let(:count) { 3 }
      it 'should return true' do
        expect(user.hit_bookings_limit?).to be true
      end
    end
    context 'over the limit' do
      let(:count) { 4 }
      it 'should return true' do
        expect(user.hit_bookings_limit?).to be true
      end
    end
  end
end
