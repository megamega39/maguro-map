# frozen_string_literal: true

# OmniAuth設定
# Deviseを使用しているため、provider登録はdevise.rb側で行う
# このファイルはOmniAuthのグローバル設定のみ

OmniAuth.config.path_prefix = "/users/auth"
OmniAuth.config.allowed_request_methods = %i[post]
OmniAuth.config.silence_get_warning = true

# リバースプロキシの背後で実行される場合、request.hostが正しくない可能性があるため、
# リダイレクトURIを生成する際に正しいホストを使用するように設定
OmniAuth.config.full_host = lambda do |env|
  if Rails.env.production?
    # 本番環境ではAPP_HOST環境変数を使用
    base_url = ENV.fetch("APP_HOST", "https://maguro-map.com").gsub(/\/$/, "")
    base_url.start_with?("http") ? base_url : "https://#{base_url}"
  else
    # 開発環境ではlocalhostを使用
    "http://localhost:3000"
  end
end
