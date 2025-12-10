class AddStatusToTasks < ActiveRecord::Migration[8.1]
  def change
    add_column :tasks, :status, :integer, default: 0, null: false # 加入 status 欄位，預設值為 0 (待處理)，且不可為 null
  end
end
