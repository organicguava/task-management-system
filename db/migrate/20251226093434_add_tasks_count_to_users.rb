class AddTasksCountToUsers < ActiveRecord::Migration[8.1]
  def change
    # 新增 tasks_count 欄位，預設值為 0，不允許 NULL
    add_column :users, :tasks_count, :integer, default: 0, null: false
  end
end
