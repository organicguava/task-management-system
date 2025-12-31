class User < ApplicationRecord
  # 啟用 bcrypt 密碼驗證
  has_secure_password

  validates :email, presence: true, uniqueness: true

  # 呼叫內部方法- ensure_admin_remains，防止刪除最後一位管理員
  before_destroy :ensure_admin_remains

  # 刪除使用者時，連帶刪除其任務，避免產生孤兒資料
  has_many :tasks, dependent: :destroy

  # 判斷是否為管理員
  def admin?
    admin # 呼叫 資料庫欄位的 getter 方法
  end

  # gem 為了安全性，要求明確指定哪些欄位可以被搜尋。防止攻擊者搜尋敏感資料（如 password_digest）。
  # 注意：不要包含敏感資料如 password_digest
  def self.ransackable_attributes(auth_object = nil)
    %w[id name email created_at updated_at tasks_count]
  end

  # Ransack 安全性設定：允許透過關聯搜尋
  def self.ransackable_associations(auth_object = nil)
    %w[tasks]
  end

  private

  def ensure_admin_remains
    if admin? && User.where(admin: true).count == 1
      errors.add(:base, :last_admin)
      throw :abort
    end
  end
end
