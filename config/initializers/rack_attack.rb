# frozen_string_literal: true

# Rack::Attack configuration for rate limiting
# Redis (Upstash) is used as the storage backend

class Rack::Attack
  # Redis接続設定（Upstash用）
  # REDIS_URL環境変数から接続情報を取得
  # テスト環境では常にメモリストアを使用
  if Rails.env.test?
    # テスト環境ではメモリストアを使用（CIでも動作するように）
    self.cache.store = ActiveSupport::Cache::MemoryStore.new
  elsif ENV["REDIS_URL"].present?
    redis_url = ENV["REDIS_URL"]
    # UpstashのURL形式に対応（redis:// または rediss://）
    self.cache.store = ActiveSupport::Cache::RedisCacheStore.new(url: redis_url)
  else
    # 開発環境でREDIS_URLが設定されていない場合はメモリストアを使用
    self.cache.store = ActiveSupport::Cache::MemoryStore.new
  end

  # ピン作成API（POST /api/pins）のみにレート制限を適用
  # 1時間あたり10回まで
  throttle("api/pins/create per hour", limit: 10, period: 1.hour) do |req|
    if req.path == "/api/pins" && req.post?
      req.ip
    end
  end

  # レート制限超過時のレスポンス
  self.throttled_responder = lambda do |env|
    retry_after = (env["rack.attack.match_data"] || {})[:period]
    [
      429,
      {
        "Content-Type" => "application/json",
        "Retry-After" => retry_after.to_s
      },
      [ { error: "短時間に投稿しすぎです。少し待ってから再度お試しください。" }.to_json ]
    ]
  end
end
