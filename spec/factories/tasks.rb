FactoryBot.define do
  factory :task do
    title { Faker::Lorem.sentence }
    content { Faker::Lorem.paragraph }
    # 之後會加入 start_time, end_time, priority 等欄位

  end
end