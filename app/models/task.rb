class Task < ApplicationRecord
  # 驗證標題必填
  validates :title, presence: true

  # 針對 TasksController#index 的查詢邏輯做封裝(原本寫在tasks_controller.rb裡面)
  scope :controller_index_query, ->(sort_by, direction) {
    # 1. 定義白名單 (原本在 Controller 裡面的邏輯)
    allowed_columns = %w[created_at end_time]
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
end
