class User < ApplicationRecord
  ROLES = %w[client owner admin].freeze

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:github]

  has_many :bookings, dependent: :destroy
  has_many :rooms, dependent: :destroy

  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :role, inclusion: { in: ROLES }

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.role = "client"
    end
  end

  def admin?
    role == "admin"
  end

  def owner?
    role == "owner"
  end

  def client?
    role == "client"
  end
end
