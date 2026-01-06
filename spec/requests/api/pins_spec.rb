require 'rails_helper'

RSpec.describe 'Api::Pins', type: :request do
  let(:valid_pin_params) do
    {
      price: 5000,
      distance_km: 5.5,
      time_slot: '昼',
      weather: '晴れ',
      lat: 35.6762,
      lng: 139.6503
    }
  end

  describe 'GET /api/pins' do
    context 'when there are no pins' do
      it 'returns empty array' do
        get '/api/pins'
        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json['status']).to eq('success')
        expect(json['data']).to eq([])
      end
    end

    context 'when there are pins' do
      let!(:pin) do
        Pin.create!(
          price: 5000,
          distance_km: 5.5,
          time_slot: '昼',
          weather: '晴れ',
          lat: 35.6762,
          lng: 139.6503,
          delete_token_digest: BCrypt::Password.create('test_token')
        )
      end

      it 'returns pins' do
        get '/api/pins'
        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json['status']).to eq('success')
        expect(json['data']).to be_an(Array)
        expect(json['data'].length).to eq(1)
      end
    end
  end

  describe 'POST /api/pins' do
    context 'with valid parameters' do
      it 'creates a new pin' do
        expect {
          post '/api/pins', params: valid_pin_params
        }.to change(Pin, :count).by(1)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['status']).to eq('success')
        expect(json['data']['pin']).to be_present
        expect(json['data']['delete_token']).to be_present
      end
    end

    context 'with invalid parameters' do
      it 'returns error when price is missing' do
        post '/api/pins', params: valid_pin_params.except(:price)
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['status']).to eq('error')
        expect(json['error']).to be_present
      end

      it 'returns error when price is too low' do
        post '/api/pins', params: valid_pin_params.merge(price: 2999)
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['status']).to eq('error')
      end

      it 'returns error when distance_km is missing' do
        post '/api/pins', params: valid_pin_params.except(:distance_km)
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['status']).to eq('error')
      end

      it 'returns error when lat is missing' do
        post '/api/pins', params: valid_pin_params.except(:lat)
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['status']).to eq('error')
      end
    end
  end

  describe 'DELETE /api/pins/:id' do
    let(:delete_token) { nil }
    let(:pin_id) { nil }

    before do
      # まずピンを作成してdelete_tokenを取得
      post '/api/pins', params: valid_pin_params
      json = JSON.parse(response.body)
      @delete_token = json['data']['delete_token']
      @pin_id = json['data']['pin']['id']
    end

    context 'with valid delete_token' do
      it 'deletes the pin' do
        expect {
          delete "/api/pins/#{@pin_id}", params: { delete_token: @delete_token }
        }.to change(Pin, :count).by(-1)

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['status']).to eq('success')
      end
    end

    context 'with invalid delete_token' do
      it 'returns unauthorized error' do
        delete "/api/pins/#{@pin_id}", params: { delete_token: 'invalid_token' }
        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json['status']).to eq('error')
        expect(json['error']).to include('削除権限がありません')
      end
    end

    context 'when pin does not exist' do
      it 'returns not found error' do
        delete '/api/pins/99999', params: { delete_token: @delete_token }
        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json['status']).to eq('error')
        expect(json['error']).to include('Pin not found')
      end
    end

    context 'without delete_token' do
      it 'returns unauthorized error' do
        delete "/api/pins/#{@pin_id}"
        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json['status']).to eq('error')
      end
    end
  end
end
