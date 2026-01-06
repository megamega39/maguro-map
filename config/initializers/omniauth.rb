# frozen_string_literal: true

# OmniAuth設定
# Deviseを使用しているため、provider登録はdevise.rb側で行う
# このファイルはOmniAuthのグローバル設定のみ

OmniAuth.config.path_prefix = "/users/auth"
OmniAuth.config.allowed_request_methods = %i[post]
OmniAuth.config.silence_get_warning = true
