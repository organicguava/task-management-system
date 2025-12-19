FactoryBot.define do
  factory :task do
    # 這告訴 FactoryBot：建立 Task 前，先自動建立一個 User 並關聯起來(若沒有這行，會因為 user_id 必填而報錯（因為現在user & task 已建立關聯）)
    association :user
    # 雖然資料庫有預設值，但為了測試穩定在 Factory 裡還是要寫出來
    title { Faker::Lorem.sentence }
    content { Faker::Lorem.paragraph }
    status { :pending }
    priority { :low }
    end_time { Time.current + 5.days }
  end
end
