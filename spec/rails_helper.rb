# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'

# 確保 Capybara 函式庫被載入，這是 Feature Spec 運作的基礎
require 'capybara/rspec'
require 'capybara/rails'

# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'

# Checks for pending migrations and applies them before tests are run.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

# 自動載入 spec/support/ 目錄下的所有支援檔案，目前是為了要用到 LoginMacros
Dir[Rails.root.join('spec', 'support', '**', '*.rb')].sort.each { |f| require f }

RSpec.configure do |config|
  # 讓 RSpec 認識 FactoryBot 的語法
  config.include FactoryBot::Syntax::Methods

  # 讓 feature spec 可以使用 t() helper
  config.include ActionView::Helpers::TranslationHelper

  config.fixture_paths = [
    Rails.root.join('spec/fixtures')
  ]

  # 讓所有 type: :feature 的測試都能使用 sign_in / sign_out 方法
  config.include LoginMacros, type: :feature

  # 必須設為 false，因為我們要手動控制 DatabaseCleaner
  # 這是避免 CI 資料殘留的關鍵設定
  config.use_transactional_fixtures = false

  # --- DatabaseCleaner 設定 (符合專案守則) ---

  # 在整個 Suite 開始前，徹底清空資料庫 (Truncation)
  # 這能解決 CI 環境中可能殘留的髒資料
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  # 每一個測試執行前後，自動切換策略
  config.around(:each) do |example|
    # 如果是 js: true (瀏覽器測試) 用 truncation，否則用 transaction
    DatabaseCleaner.strategy = example.metadata[:js] ? :truncation : :transaction

    DatabaseCleaner.cleaning do
      example.run
    end
  end
  # --- DatabaseCleaner 設定結束 ---

  # --- Capybara Driver 切換設定 ---
  config.before(:each, type: :feature, js: true) do
    if ENV['JS_BROWSER_VISIBLE'].to_i == 1
      Capybara.current_driver = :selenium_chrome
    else
      Capybara.current_driver = :selenium_chrome_headless_in_ci
    end
  end

  # 確保此設定在 configure 區塊內
  config.filter_rails_from_backtrace!
end
