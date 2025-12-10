class AddIndexToTasks < ActiveRecord::Migration[8.1]
  def change
      # 為 status 加索引 (因為我們常用 status 做精確查詢)
      add_index :tasks, :status

      # 為 title 加索引 (注意：標準 B-Tree 索引對 'LIKE %keyword%' 效果有限，但對 'keyword%' 有效)
      # 在這裡我們還是加上去，示範 index 的建立
      add_index :tasks, :title
    end
end
