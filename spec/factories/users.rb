FactoryBot.define do
  factory :user do
    name { Faker::Name.name }

    # 使用 Faker 確保 email 唯一，避免測試相撞
    email { Faker::Internet.unique.email }

    # 設定明碼 password，讓 model 幫我們加密
    password { "123456" }
  end
end
