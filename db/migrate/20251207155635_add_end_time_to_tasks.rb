class AddEndTimeToTasks < ActiveRecord::Migration[8.1]
  def change
    add_column :tasks, :end_time, :datetime
  end
end
