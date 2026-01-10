class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    # OmniAuthから認証情報を取得
    auth = request.env["omniauth.auth"]

    # メールアドレスが取得できない場合はエラー
    unless auth.info&.email.present?
      Rails.logger.error "OmniAuth: Email not provided by Google"
      redirect_to root_path(login: "failed"), alert: "メールアドレスが取得できませんでした。Googleアカウントのメールアドレスが公開されていることを確認してください。"
      return
    end

    # Userモデルのfrom_omniauthメソッドを使用してユーザーを検索または作成
    user = User.from_omniauth(auth)

    # ユーザーをログインさせる
    sign_in(user, event: :authentication)
    redirect_to root_path(login: "success"), notice: "ログインに成功しました"

  rescue => e
    Rails.logger.error "OmniAuth error: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    redirect_to root_path(login: "failed"), alert: "Googleログインに失敗しました: #{e.message}"
  end

  def failure
    redirect_to root_path(login: "failed"), alert: "認証に失敗しました"
  end
end
