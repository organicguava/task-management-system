# 專案特殊守則 (Project Guardrails) - Task Management System

## 1. 測試資料庫清潔策略 (Critical)
本專案採用 **DatabaseCleaner** 來解決 CI 環境髒資料問題，而非 Rails 預設機制。
在 Review 程式碼或協助除錯時，請務必遵守以下檢查點：

* **絕對禁止**：建議使用者刪除 `spec/rails_helper.rb` 中的 `DatabaseCleaner` 設定區塊。
* **絕對禁止**：建議使用者將 `config.use_transactional_fixtures` 改回 `true` (除非已完全移除 DatabaseCleaner)。
* **檢查邏輯**：
    * 若使用者遇到 RSpec 資料殘留問題，優先檢查 `DatabaseCleaner.clean_with(:truncation)` 是否存在於 `before(:suite)`。
    * 若使用者新增 Feature Spec，提醒不需要手動寫 `delete_all`，因為全域設定已處理。

## 2. Gemfile 依賴
* 確保 `database_cleaner-active_record` 始終存在於 `group :test` 中。