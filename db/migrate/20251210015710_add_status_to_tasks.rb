class AddStatusToTasks < ActiveRecord::Migration[8.1]
  def change
      # 使用 change_table 搭配 bulk: true，讓 DB 一次做完所有事
      change_table :tasks, bulk: true do |t|
        t.integer :status, default: 0, null: false
        t.index :status
        t.index :title
      end
    end
end
