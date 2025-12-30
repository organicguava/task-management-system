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

## 3. Inline SVG 使用規範
當需要在 View 中使用 inline SVG 圖示時，請使用 `inline_svg` gem，而非直接嵌入 SVG 原始碼。

### 為什麼使用 inline_svg gem：
* 保持 View 檔案整潔易維護
* SVG 檔案統一存放在 `app/assets/images/`，方便重複使用
* 支援透過 CSS class 動態調整樣式
* 可直接傳入 HTML 屬性

### 使用方式：
```erb
<%= inline_svg_tag "icon_name.svg", class: "w-5 h-5 text-gray-500" %>
```

### 設定（若尚未安裝）：
1. 在 Gemfile 加入：`gem 'inline_svg'`
2. 執行 `bundle install`
3. 將 SVG 檔案放置於 `app/assets/images/`

### 禁止事項：
* **絕對禁止**：在 `.html.erb` 模板中直接嵌入大段 inline SVG 程式碼
* **絕對禁止**：複製貼上原始 SVG markup 到 View 中

### 建議做法：
* 將 SVG 檔案獨立存放於 assets 資料夾
* 使用 `inline_svg_tag` helper 來渲染 SVG