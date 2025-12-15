class Task < ApplicationRecord
  # 驗證標題必填
  validates :title, presence: true
  validates :status, presence: true
  validates :priority, presence: true

  # 定義status：待處理 (0), 進行中 (1), 完成 (2)
  enum :status, { pending: 0, processing: 1, completed: 2 }

  # 定義priority：低 (0), 中 (1), 高 (2), 預設為低 (0)
  enum :priority, { low: 0, medium: 1, high: 2 }

  # 為了安全性（避免惡意使用者試探你的資料庫欄位），你必須在 Model 裡明確定義「哪些欄位可以被搜尋」
  # 定義 Ransack 可以搜尋的欄位 (白名單)
  def self.ransackable_attributes(auth_object = nil)
    [ "title", "content", "status", "priority", "start_time", "end_time", "created_at" ]
  end

  # 定義 Ransack 可以搜尋的關聯 (如果之後有 User 或 Tag 的話)
  def self.ransackable_associations(auth_object = nil)
    []
  end

  # 搜尋邏輯放在model scope 而非controller , 維持fat controller thin model 原則

  # 針對 TasksController#index 的查詢邏輯做封裝(原本寫在tasks_controller.rb裡面)
  scope :controller_index_query, ->(sort_by, direction) {
    # 1. 定義白名單 (原本在 Controller 裡面的邏輯)
    allowed_columns = %w[created_at end_time priority]
    allowed_directions = %w[asc desc]

    # 2. 檢查與設定預設值
    # 如果傳進來的欄位在白名單內就用它，不然就預設 'created_at'
    safe_column = allowed_columns.include?(sort_by) ? sort_by : "created_at"

    # 如果傳進來的方向在白名單內就用它，不然就預設 'desc'
    # 把direction寫活，保留彈性，不再查詢時寫：order("#{safe_column} DESC NULLS LAST")
    safe_direction = allowed_directions.include?(direction) ? direction : "desc"

    # 3. 執行查詢 (PostgreSQL 語法)
    order("#{safe_column} #{safe_direction} NULLS LAST")
  }

  # 標題模糊搜尋
  scope :search_by_title, ->(keyword) {
    keyword.present? ? where("title LIKE ?", "%#{keyword}%") : all # 有值就搜尋，沒值就回傳全部
  }

  # 狀態精確搜尋
  scope :search_by_status, ->(status) {
    status.present? ? where(status: status) : all
  }

  # 優先順序精確搜尋
  scope :search_by_priority, ->(priority) { priority.present? ? where(priority: priority) : all }
end
