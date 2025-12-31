FactoryBot.define do
  factory :user do
    name { Faker::Name.name }

    # 使用 Faker 確保 email 唯一，避免測試相撞
    email { Faker::Internet.unique.email }

    # 設定明碼 password，讓 model 幫我們加密
    password { "123456" }

    # 新增 admin trait(可以在factory 上疊加額外屬性，用來切換角色)
    trait :admin do
      admin { true }
    end
  end
end
