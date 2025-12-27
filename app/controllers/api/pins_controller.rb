class Api::PinsController < ApplicationController
  # CORS対応
  skip_before_action :verify_authenticity_token

  # エラーハンドリング
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActionController::ParameterMissing, with: :parameter_missing

  # ピンの一覧取得
  def index
    pins = Pin.order(created_at: :desc).limit(1000) # 最新1000件まで
    render json: {
      status: "success",
      data: pins.map { |pin| pin_json(pin) }
    }
  end

  # ピンの作成
  def create
    # delete_tokenを生成
    delete_token = SecureRandom.urlsafe_base64(32)
    delete_token_digest = BCrypt::Password.create(delete_token)

    pin = Pin.new(pin_params.merge(delete_token_digest: delete_token_digest))

    if pin.save
      render json: {
        status: "success",
        data: {
          pin: pin_json(pin),
          delete_token: delete_token # 初回のみ返す
        }
      }, status: :created
    else
      render json: {
        status: "error",
        errors: pin.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  # ピンの削除
  def destroy
    pin = Pin.find_by(id: params[:id])
    
    unless pin
      render json: {
        status: "error",
        error: "Pin not found"
      }, status: :not_found
      return
    end

    # delete_tokenで認証
    delete_token = params[:delete_token]
    unless delete_token && BCrypt::Password.new(pin.delete_token_digest) == delete_token
      render json: {
        status: "error",
        error: "Invalid delete token"
      }, status: :unauthorized
      return
    end

    if pin.destroy
      render json: {
        status: "success",
        message: "Pin deleted successfully"
      }, status: :ok
    else
      render json: {
        status: "error",
        errors: pin.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  private

  def pin_params
    # JSON形式でもフォーム形式でも受け取れるようにする
    if params[:pin].present?
      params.require(:pin).permit(:price, :distance_km, :time_slot, :weather, :lat, :lng)
    else
      params.permit(:price, :distance_km, :time_slot, :weather, :lat, :lng)
    end
  end

  def pin_json(pin)
    {
      id: pin.id,
      price: pin.price,
      distance_km: pin.distance_km.to_f,
      time_slot: pin.time_slot,
      weather: pin.weather,
      lat: pin.lat.to_f,
      lng: pin.lng.to_f,
      icon_type: pin.icon_type,
      created_at: pin.created_at.iso8601
    }
  end

  def record_not_found
    render json: {
      status: "error",
      error: "Record not found"
    }, status: :not_found
  end

  def parameter_missing(exception)
    render json: {
      status: "error",
      error: "Parameter missing: #{exception.param}"
    }, status: :bad_request
  end
end

