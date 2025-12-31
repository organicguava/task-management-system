class AddAdminToUsers < ActiveRecord::Migration[8.1]
  def change
    # 新的user預設不是管理員；欄位不能是 null
    add_column :users, :admin, :boolean, default: false, null: false
  end
end
