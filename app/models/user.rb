class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  has_many :pins, dependent: :destroy

  # ロール定義（enum: user=0, admin=1）
  enum :role, { user: 0, admin: 1 }

  # Deviseのemail認証を使用するため、user_nameはオプション扱い
  validates :user_name, presence: true, if: -> { new_record? || user_name_changed? }

  # 共有マップ用トークンを生成
  def generate_share_map_token!
    token = SecureRandom.urlsafe_base64(32)
    self.share_map_token_digest = BCrypt::Password.create(token)
    save!
    token
  end

  # 共有マップ用トークンを検証
  def share_map_token_valid?(token)
    return false if share_map_token_digest.blank?
    BCrypt::Password.new(share_map_token_digest) == token
  rescue BCrypt::Errors::InvalidHash
    false
  end

  # OmniAuthからユーザーを検索または作成
  def self.from_omniauth(auth)
    # メールアドレスが必須
    unless auth.info&.email.present?
      raise "Email is required but not provided by OAuth provider"
    end
    
    # providerとuidで既存ユーザーを検索
    user = find_by(provider: auth.provider, uid: auth.uid)
    
    # 見つからない場合、emailで検索
    if user.nil?
      user = find_by(email: auth.info.email)
      # emailが一致する既存ユーザーが見つかった場合、providerとuidを更新
      if user && (user.provider.blank? || user.uid.blank?)
        user.update(provider: auth.provider, uid: auth.uid)
      end
    end
    
    # まだ見つからない場合、新規ユーザーを作成
    if user.nil?
      user = create!(
        email: auth.info.email,
        user_name: auth.info.name.presence || auth.info.email.split('@').first,
        provider: auth.provider,
        uid: auth.uid,
        password: Devise.friendly_token[0, 20] # ランダムなパスワードを生成
      )
    end
    
    user
  end
end
