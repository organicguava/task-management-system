class Tag < ApplicationRecord
  # 透過中間表與 Task 建立多對多關聯
  has_many :task_tags, dependent: :destroy
  has_many :tasks, through: :task_tags


  validates :name, presence: true, uniqueness: true


  # 定義 Ransack 可以搜尋的欄位 (白名單)
  # 包含 id 以支援 tasks 的標籤篩選功能（tags_id_eq）
  def self.ransackable_attributes(auth_object = nil)
    %w[id name]
  end

  # 定義 Ransack 可以搜尋的關聯
  def self.ransackable_associations(auth_object = nil)
    %w[tasks]
  end
end
