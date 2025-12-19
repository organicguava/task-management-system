class User < ApplicationRecord
  # 啟用 bcrypt 密碼驗證
  has_secure_password

  validates :email, presence: true, uniqueness: true
  # 刪除使用者時，連帶刪除其任務，避免產生孤兒資料
  has_many :tasks, dependent: :destroy
end
