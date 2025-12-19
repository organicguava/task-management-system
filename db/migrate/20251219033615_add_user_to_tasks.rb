class AddUserToTasks < ActiveRecord::Migration[8.1]
  def up
    # 1. 新增欄位 (允許 NULL)
    add_reference :tasks, :user, null: true, foreign_key: true

    # 2. 引入 BCrypt 並手動產生加密密碼
    # 用意：即使 User Model 還沒寫好 has_secure_password，這段程式碼也能跑
    require 'bcrypt'
    digest = BCrypt::Password.create('123456')

    # 3. 建立預設使用者
    default_user = User.find_or_create_by(email: 'admin@example.com') do |u|
      u.name = 'Admin'
      u.password_digest = digest # password 直接寫入資料庫欄位，而非虛擬欄位 password
    end

    # 4. 更新舊資料
    Task.where(user_id: nil).update_all(user_id: default_user.id)

    # 5. 加回 NOT NULL 限制
    change_column_null :tasks, :user_id, false
  end

  def down
    remove_reference :tasks, :user
  end
end
