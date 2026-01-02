class TaskTag < ApplicationRecord
  # === 關聯 ===
  # 中間表同時屬於 Task 和 Tag
  belongs_to :task
  belongs_to :tag

  # === 驗證 ===
  # 確保同一任務不會重複加入相同標籤（搭配資料庫唯一索引的雙重保護）
  validates :tag_id, uniqueness: { scope: :task_id, message: :already_added }
end
