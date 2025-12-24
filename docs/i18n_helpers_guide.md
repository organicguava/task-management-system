# Rails i18n Helpers 完整指南

## 📌 概述

在 Rails 應用中，有兩個常用的國際化 helpers 用於顯示文字：
- **`t()` helper**：通用的國際化翻譯 helper
- **`.human_attribute_name()` helper**：針對 Model 屬性的自動翻譯 helper

---

## 1. `t()` Helper（翻譯 Helper）

### 定義
`t()` 是 `I18n.translate()` 的別名，用於翻譯任意文字。

### 使用時機
✅ **適合翻譯以下內容：**
- 頁面標題（page titles）
- 按鈕文字（button labels）
- 連結文字（link text）
- 提示訊息（flash messages）
- UI 文案（navigation, descriptions）
- 頁面特定的文字

### 運作流程

```
View File（.html.erb）
    ↓
<%= t("sessions.new.title") %>
    ↓
Rails 在以下檔案中查找翻譯
    ↓
config/locales/[locale].yml
    ↓
zh-TW.yml:
  sessions:
    new:
      title: "登入系統"
    ↓
en.yml:
  sessions:
    new:
      title: "Sign in to your account"
    ↓
根據當前 locale 返回對應翻譯
```

### 具體例子

**在 View 中使用：**
```erb
<!-- app/views/sessions/new.html.erb -->
<h2><%= t("sessions.new.title") %></h2>
<%= f.submit t("sessions.new.submit") %>
<%= link_to t("sessions.new.register_link"), signup_path %>
```

**翻譯檔案配置：**
```yaml
# config/locales/zh-TW.yml
zh-TW:
  sessions:
    new:
      title: "登入系統"
      submit: "登入"
      register_link: "註冊新帳號"

# config/locales/en.yml
en:
  sessions:
    new:
      title: "Sign in to your account"
      submit: "Sign in"
      register_link: "Sign up for a new account"
```

### 優點 ✨
- ✅ **彈性高**：可以翻譯任何文字
- ✅ **層級清晰**：按照功能/頁面組織翻譯（如 `sessions.new`, `users.new`）
- ✅ **易於管理**：集中在翻譯檔案中，方便修改
- ✅ **支持參數插值**：`t("hello", name: "John")` → "Hello John"

---

## 2. `.human_attribute_name()` Helper

### 定義
`.human_attribute_name()` 是 ActiveRecord 提供的方法，專門用於將 Model 的屬性名稱轉換為人類可讀的文字。

### 使用時機
✅ **適合翻譯以下內容：**
- Model 屬性標籤（form labels）
- Model 欄位名稱（column names）
- Model 驗證錯誤訊息

❌ **不適合翻譯：**
- 頁面文案
- 按鈕文字
- UI 訊息

### 運作流程

```
View File（.html.erb）
    ↓
<%= f.label :email, User.human_attribute_name(:email) %>
    ↓
Rails Model（User）
    ↓
查詢 activerecord.attributes 的翻譯
    ↓
config/locales/[locale].yml
    ↓
zh-TW.yml:
  activerecord:
    attributes:
      user:
        email: "電子信箱"
    ↓
en.yml:
  activerecord:
    attributes:
      user:
        email: "Email"
    ↓
返回對應翻譯
```

### 具體例子

**在 View 中使用：**
```erb
<!-- app/views/users/new.html.erb -->
<%= f.label :email, User.human_attribute_name(:email), class: "..." %>
<%= f.email_field :email %>

<!-- 或者簡寫方式（Rails 會自動使用 human_attribute_name） -->
<%= f.label :email %>  <!-- 自動變成 "Email" 或 "電子信箱" -->
```

**翻譯檔案配置：**
```yaml
# config/locales/zh-TW.yml
zh-TW:
  activerecord:
    models:
      user: "使用者"
    attributes:
      user:
        name: "名稱"
        email: "電子信箱"
        password: "密碼"
        password_confirmation: "確認密碼"

# config/locales/en.yml
en:
  activerecord:
    models:
      user: "User"
    attributes:
      user:
        name: "Name"
        email: "Email"
        password: "Password"
        password_confirmation: "Password Confirmation"
```

### 優點 ✨
- ✅ **集中管理**：所有 Model 屬性翻譯在一個地方
- ✅ **自動應用**：驗證錯誤訊息會自動使用這些翻譯
- ✅ **DRY**：避免在多個地方重複定義相同的翻譯
- ✅ **一致性**：確保所有表單和驗證訊息使用相同的屬性名稱

---

## 3. 對比表格

| 特性 | `t()` Helper | `.human_attribute_name()` |
|------|-------------|--------------------------|
| **用途** | 翻譯任意 UI 文字 | 翻譯 Model 屬性名稱 |
| **配置位置** | 自訂位置（pages, sessions, users 等） | `activerecord.attributes` 下 |
| **使用範圍** | 頁面標題、按鈕、連結、訊息 | 表單標籤、驗證錯誤 |
| **Model 依賴** | ❌ 不依賴 Model | ✅ 依賴 Model |
| **自動套用** | ❌ 需要手動在 view 中使用 | ✅ 驗證錯誤自動套用 |
| **複用性** | 👎 頁面特定，難以複用 | 👍 跨頁面複用 |
| **彈性** | 👍 非常高 | 👎 僅限 Model 屬性 |

---

## 4. 實際應用例子

### 情境：User Registration Form

**View: `app/views/users/new.html.erb`**
```erb
<h2><%= t("users.new.title") %></h2>  <!-- ← 使用 t() -->

<%= form_with(model: @user, local: true) do |f| %>
  <!-- 使用 human_attribute_name() 翻譯屬性標籤 -->
  <%= f.label :name, User.human_attribute_name(:name) %>
  <%= f.text_field :name %>

  <%= f.label :email, User.human_attribute_name(:email) %>
  <%= f.email_field :email %>

  <%= f.label :password, User.human_attribute_name(:password) %>
  <%= f.password_field :password %>

  <!-- 使用 t() 翻譯按鈕文字 -->
  <%= f.submit t("users.new.submit") %>

  <!-- 使用 t() 翻譯連結文字 -->
  <%= link_to t("users.new.login_link"), login_path %>
<% end %>
```

**翻譯檔案配置：**
```yaml
# config/locales/zh-TW.yml
zh-TW:
  activerecord:
    models:
      user: "使用者"
    attributes:
      user:
        name: "名稱"
        email: "電子信箱"
        password: "密碼"
        password_confirmation: "確認密碼"
  
  users:
    new:
      title: "註冊新帳號"
      submit: "註冊"
      login_link: "登入現有帳號"
```

**當驗證失敗時，自動生成錯誤訊息：**
```
❌ "名稱不能為空"  ← 自動使用 activerecord.attributes.user.name 的翻譯
❌ "電子信箱已存在"  ← 自動使用 activerecord.attributes.user.email 的翻譯
```

---

## 5. 使用決策流程圖

```
我需要翻譯一個文字
    ↓
它是 Model 的屬性名稱嗎？
（如：email, password, name）
    ↓
   是 → 使用 .human_attribute_name()
    ↓    例：User.human_attribute_name(:email)
   否 ↓
    ↓
它是頁面特定的文字嗎？
（如：標題、按鈕、連結、訊息）
    ↓
   是 → 使用 t() helper
    ↓    例：t("users.new.title")
   否 ↓
    ↓
它是通用的詞彙嗎？
（如：編輯、刪除、保存）
    ↓
   是 → 在 common: 下定義，使用 t()
    ↓    例：t("action.edit")
   否 ↓
    ↓
使用 t() 在合適的位置定義
```

---

## 6. 最佳實踐

### ✅ DO（應該做）

1. **屬性標籤使用 `.human_attribute_name()`**
   ```erb
   <%= f.label :email, User.human_attribute_name(:email) %>
   ```

2. **頁面文案使用 `t()`**
   ```erb
   <h1><%= t("users.new.title") %></h1>
   ```

3. **按層級組織 i18n 翻譯**
   ```yaml
   users:          # 模組/功能
     new:          # 動作
       title: "..." # 具體翻譯
   ```

4. **避免重複定義**
   ```yaml
   # ✅ 好：定義一次，多處複用
   activerecord:
     attributes:
       user:
         email: "電子信箱"
   ```

### ❌ DON'T（不應該做）

1. **不要硬編碼中文**
   ```erb
   <!-- ❌ 不好 -->
   <h1>註冊新帳號</h1>
   <label>電子信箱</label>
   ```

2. **不要混淆用途**
   ```erb
   <!-- ❌ 不好：用 human_attribute_name 翻譯頁面標題 -->
   <%= f.label :page_title, User.human_attribute_name(:page_title) %>
   ```

3. **不要在 Controller 中翻譯屬性名稱**
   ```ruby
   # ❌ 不好
   name_label = I18n.t("activerecord.attributes.user.name")
   
   # ✅ 好：在 view 中翻譯
   <%= User.human_attribute_name(:name) %>
   ```

---

## 7. 檔案結構參考

```
task-management-system/
├── app/
│   ├── views/
│   │   ├── users/
│   │   │   └── new.html.erb         ← 在此使用 t() 和 human_attribute_name()
│   │   ├── sessions/
│   │   │   └── new.html.erb         ← 在此使用 t() 和 human_attribute_name()
│   │   └── tasks/
│   │       └── new.html.erb
│   ├── models/
│   │   └── user.rb                  ← Model 定義（無需改動）
│   └── controllers/
│       └── users_controller.rb      ← Controller（使用 flash.notice）
│
└── config/
    └── locales/                     ← 所有翻譯檔案在此
        ├── zh-TW.yml               ← 中文翻譯
        ├── en.yml                  ← 英文翻譯
        └── ...
```

---

## 8. 在本應用中的應用案例

### User Registration (`users/new.html.erb`)
```erb
<!-- 頁面標題：使用 t() -->
<h2><%= t("users.new.title") %></h2>

<!-- 表單標籤：使用 human_attribute_name() -->
<%= f.label :name, User.human_attribute_name(:name) %>
<%= f.label :email, User.human_attribute_name(:email) %>
<%= f.label :password, User.human_attribute_name(:password) %>
<%= f.label :password_confirmation, User.human_attribute_name(:password_confirmation) %>

<!-- 按鈕和連結：使用 t() -->
<%= f.submit t("users.new.submit") %>
<%= link_to t("users.new.login_link"), login_path %>
```

**對應翻譯配置：**
```yaml
# config/locales/zh-TW.yml
zh-TW:
  activerecord:
    attributes:
      user:
        name: "名稱"
        email: "電子信箱"
        password: "密碼"
        password_confirmation: "確認密碼"
  
  users:
    new:
      title: "註冊新帳號"
      submit: "註冊"
      login_link: "登入現有帳號"
```

### Login (`sessions/new.html.erb`)
```erb
<!-- 頁面標題：使用 t() -->
<h2><%= t("sessions.new.title") %></h2>

<!-- 表單標籤：使用 human_attribute_name() -->
<%= f.label :email, User.human_attribute_name(:email) %>
<%= f.label :password, User.human_attribute_name(:password) %>

<!-- 按鈕和連結：使用 t() -->
<%= f.submit t("sessions.new.submit") %>
<%= link_to t("sessions.new.register_link"), signup_path %>
```

**對應翻譯配置：**
```yaml
# config/locales/zh-TW.yml
zh-TW:
  sessions:
    new:
      title: "登入系統"
      submit: "登入"
      register_link: "註冊新帳號"
```

---

## 9. 常見問題

### Q: 為什麼 `f.label :email` 自動變成翻譯？
A: Rails 的 form builder 會自動調用 `human_attribute_name()` 方法。如果你想指定自訂標籤，可以傳遞第二個參數：
```erb
<%= f.label :email, "Email Address" %>  <!-- 使用自訂文字 -->
<%= f.label :email, User.human_attribute_name(:email) %>  <!-- 顯式使用翻譯 -->
```

### Q: 如何在 Controller 中使用翻譯？
A: 在 Controller 中使用 `I18n.t()` 或 `t()` helper：
```ruby
# app/controllers/sessions_controller.rb
def create
  # ...
  redirect_to root_path, notice: t("flash.auth.login")
end
```

### Q: 如何支援多個語言？
A: 建立不同的翻譯檔案並在應用中設定預設 locale：
```ruby
# config/application.rb
config.i18n.default_locale = :zh_TW
config.i18n.available_locales = [:zh_TW, :en]
```

---

## 總結

| 場景 | 使用 | 原因 |
|------|------|------|
| 表單欄位標籤 | `.human_attribute_name()` | Model 屬性的標準翻譯方式 |
| 頁面標題 | `t()` | 頁面特定文案 |
| 按鈕文字 | `t()` | UI 文案 |
| 連結文字 | `t()` | UI 文案 |
| Flash 訊息 | `t()` | 訊息文案 |
| 驗證錯誤 | `.human_attribute_name()` 自動套用 | Rails 自動組合「屬性名 + 驗證訊息」 |

