class Task < ApplicationRecord
  # 驗證標題必填
  validates :title, presence: true
end
