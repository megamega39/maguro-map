require 'rails_helper'

RSpec.describe Pin, type: :model do
  describe 'validations' do
    let(:valid_attributes) do
      {
        price: 5000,
        distance_km: 5.5,
        time_slot: '昼',
        weather: '晴れ',
        lat: 35.6762,
        lng: 139.6503,
        delete_token_digest: BCrypt::Password.create('test_token')
      }
    end

    context 'when all attributes are valid' do
      it 'is valid' do
        pin = Pin.new(valid_attributes)
        expect(pin).to be_valid
      end
    end

    describe 'price' do
      it 'is required' do
        pin = Pin.new(valid_attributes.except(:price))
        expect(pin).not_to be_valid
        expect(pin.errors[:price]).to be_present
      end

      it 'must be an integer' do
        pin = Pin.new(valid_attributes.merge(price: 5000.5))
        expect(pin).not_to be_valid
        expect(pin.errors[:price]).to be_present
      end

      it 'must be greater than or equal to 3000' do
        pin = Pin.new(valid_attributes.merge(price: 2999))
        expect(pin).not_to be_valid
        expect(pin.errors[:price]).to be_present
      end

      it 'must be less than or equal to 9999' do
        pin = Pin.new(valid_attributes.merge(price: 10000))
        expect(pin).not_to be_valid
        expect(pin.errors[:price]).to be_present
      end
    end

    describe 'distance_km' do
      it 'is required' do
        pin = Pin.new(valid_attributes.except(:distance_km))
        expect(pin).not_to be_valid
        expect(pin.errors[:distance_km]).to be_present
      end

      it 'must be greater than or equal to 0.1' do
        # 0.0は0.1未満なので無効であるべき
        pin = Pin.new(valid_attributes.merge(distance_km: 0.0))
        expect(pin).not_to be_valid
        expect(pin.errors[:distance_km]).to be_present
      end

      it 'allows 0.1 as minimum value' do
        pin = Pin.new(valid_attributes.merge(distance_km: 0.1))
        expect(pin).to be_valid
      end

      it 'must be less than or equal to 99.9' do
        pin = Pin.new(valid_attributes.merge(distance_km: 100.0))
        expect(pin).not_to be_valid
        expect(pin.errors[:distance_km]).to be_present
      end
    end

    describe 'time_slot' do
      it 'is required' do
        pin = Pin.new(valid_attributes.except(:time_slot))
        expect(pin).not_to be_valid
        expect(pin.errors[:time_slot]).to be_present
      end
    end

    describe 'weather' do
      it 'is required' do
        pin = Pin.new(valid_attributes.except(:weather))
        expect(pin).not_to be_valid
        expect(pin.errors[:weather]).to be_present
      end
    end

    describe 'lat' do
      it 'is required' do
        pin = Pin.new(valid_attributes.except(:lat))
        expect(pin).not_to be_valid
        expect(pin.errors[:lat]).to be_present
      end

      it 'must be greater than or equal to -90' do
        pin = Pin.new(valid_attributes.merge(lat: -91))
        expect(pin).not_to be_valid
        expect(pin.errors[:lat]).to be_present
      end

      it 'must be less than or equal to 90' do
        pin = Pin.new(valid_attributes.merge(lat: 91))
        expect(pin).not_to be_valid
        expect(pin.errors[:lat]).to be_present
      end
    end

    describe 'lng' do
      it 'is required' do
        pin = Pin.new(valid_attributes.except(:lng))
        expect(pin).not_to be_valid
        expect(pin.errors[:lng]).to be_present
      end

      it 'must be greater than or equal to -180' do
        pin = Pin.new(valid_attributes.merge(lng: -181))
        expect(pin).not_to be_valid
        expect(pin.errors[:lng]).to be_present
      end

      it 'must be less than or equal to 180' do
        pin = Pin.new(valid_attributes.merge(lng: 181))
        expect(pin).not_to be_valid
        expect(pin.errors[:lng]).to be_present
      end
    end

    describe 'delete_token_digest' do
      it 'is required' do
        pin = Pin.new(valid_attributes.except(:delete_token_digest))
        expect(pin).not_to be_valid
        expect(pin.errors[:delete_token_digest]).to be_present
      end
    end
  end
end
