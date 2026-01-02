

# 1. 清除舊資料 (為了避免 Foreign Key 報錯，必須先刪除關聯再刪除主表)
puts "正在清除舊資料..."
TaskTag.delete_all
Task.delete_all
Tag.delete_all
User.delete_all

# 2. 建立預設標籤
puts "建立預設標籤..."
tags = %w[工作 個人 學習].map do |name|
  Tag.create!(name: name)
end
puts "共建立 #{Tag.count} 個標籤"

# 3. 建立預設使用者
puts "建立預設使用者..."
# 建立一個固定帳號，方便之後登入測試
admin = User.create!(
  name: "Admin",
  email: "admin@example.com",
  password: "123456",             # has_secure_password 會自動加密
  password_confirmation: "123456",
  admin: true
)

# 5. 建立任務
puts "正在建立測試任務..."

# 產生 50 筆資料即可，足以測試分頁 (預設 10 筆一頁，會有 5 頁)
# 避免產生上萬筆資料干擾測試與開發視覺
50.times do |i|
  task = Task.create!(
    title: "測試任務 #{i + 1}: #{Faker::Lorem.sentence(word_count: 3)}",
    content: Faker::Lorem.paragraph,
    end_time: Faker::Time.forward(days: 30),
    status: Task.statuses.keys.sample,     # 隨機狀態
    priority: Task.priorities.keys.sample, # 隨機優先順序
    user: admin                            # 關鍵：將任務指派給上面的使用者
  )
  # 隨機為任務加入 0~3 個標籤
  task.tags = tags.sample(rand(0..3))
end

puts "建立完成！"
puts "使用者: admin@example.com / 123456"
puts "共建立 #{Task.count} 筆任務"
puts "共建立 #{TaskTag.count} 筆任務-標籤關聯"
