class CreateTags < ActiveRecord::Migration[8.1]
  def change
    create_table :tags do |t|
      t.string :name, null: false

      t.timestamps
    end

    # 標籤名稱不可重複
    add_index :tags, :name, unique: true
  end
end
