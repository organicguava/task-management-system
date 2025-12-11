if Rails.env.development?
  puts "清除舊資料..."
  # 使用 delete_all 比較快，因為你要刪除一萬筆，用 destroy_all 會跑很久
  Task.delete_all
end

puts "正在製造 10,000 筆任務..."

10000.times do |i|
  Task.create!(
    title: Faker::Lorem.sentence(word_count: 3),
    content: Faker::Lorem.paragraph,
    end_time: Faker::Time.forward(days: 30),
    status: Task.statuses.keys.sample # 隨機狀態
  )
end
