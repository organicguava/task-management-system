class AddPriorityToTasks < ActiveRecord::Migration[8.1]
  def change
    change_table :tasks, bulk: true do |t|
      t.integer :priority, default: 0, null: false
      t.index :priority

      # 補上漏掉的：End Time Index
      t.index :end_time
    end
  end
end
