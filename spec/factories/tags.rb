FactoryBot.define do
  factory :tag do
    # 使用 sequence 確保每個標籤名稱唯一，避免唯一性驗證失敗
    # 使用英文名稱以支援 shoulda-matchers 的大小寫測試
    sequence(:name) { |n| "Tag#{n}" }

    # 預定義一些常用標籤的 trait
    trait :work do
      name { "工作" }
    end

    trait :personal do
      name { "個人" }
    end

    trait :urgent do
      name { "緊急" }
    end
  end
end
