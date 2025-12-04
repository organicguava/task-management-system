class AddNotNullConstraintToTasksTitle < ActiveRecord::Migration[8.1]
  def change
    # 將 tasks 表格的 title 欄位設為無法接受 null
    change_column_null :tasks, :title, false
  end
end
