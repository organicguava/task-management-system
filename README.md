# README

## Database Schema

### users  

| Column Name | Data Type |
| :--- | :--- |
| `id` | `integer` | 
| `name` | `string` | 
| `email` | `string` | 
| `password` | `string` | 
| `role` | `integer` | 
| `created_at` | `datetime` | 
| `updated_at` | `datetime` |           


### tasks    

| Column Name | Data Type |
| :--- | :--- |
| `id` | `integer` | 
| `user_id` | `integer` | 
| `title` | `string` | 
| `content` | `text` | 
| `start_time` | `datetime` | 
| `end_time` | `datetime` | 
| `priority` | `integer` | 
| `status` | `integer` | 
| `created_at` | `datetime` | 
| `updated_at` | `datetime` | 

### task_tags  

| Column Name | Data Type |
| :--- | :--- |
| `id` | `integer` | 
| `task_id` | `integer` | 
| `tag_id` | `integer` | 


### tags    

| Column Name | Data Type |
| :--- | :--- |
| `id` | `integer` | 
| `name` | `string` | 
| `created_at` | `datetime` | 
| `updated_at` | `datetime` | 

---  

## 網站連結與測試帳號 
- 網址：(https://task-manager-v0pr.onrender.com)
- Basic Auth 帳號：admin123 
- Basic Auth 密碼：666666

---  

## Tech Stack

### 核心框架
- **Ruby**: 3.4.7
- **Ruby on Rails**: 8.1.1
- **Database**: PostgreSQL (pg ~> 1.6)

### 前端技術
- **CSS Framework**: TailwindCSS v4 (透過 `tailwindcss-rails` gem)
- **JavaScript**: Hotwire (Turbo + Stimulus) with Importmaps
- **Icon**: FontAwesome / Heroicons

### 系統套件
- **Web Server**: Puma (>= 5.0)
- **Assets**: Propshaft (Rails 8 預設 Asset Pipeline)

## 佈署方式 

使用 **Render** 平台搭配 **Docker** 進行自動化佈署。

### 佈署架構
- **Platform**: Render (Blueprint / Infrastructure as Code)
- **Containerization**: 使用 Rails 8 內建的 `Dockerfile` 進行容器化。
- **Region**: Singapore (Web Service 與 Database 均位於同一地區以確保連線)。

### 操作流程
1. **設定檔 (`render.yaml`)**:
   專案根目錄包含 `render.yaml`，定義了 Web Service 與 PostgreSQL 資料庫的關聯。
2. **環境變數**:
   在 Render Dashboard 中設定了以下關鍵變數：
   - `RAILS_MASTER_KEY`: 用於解密 Production credentials。
   - `RAILS_SERVE_STATIC_FILES`: 設為 `true`，強制 Puma 處理靜態檔案（解決 CSS/JS 載入問題）。
   - `ADMIN_USERNAME` / `ADMIN_PASSWORD`: 設定 Basic Auth 登入資訊。
3. **持續整合 (CI/CD)**:
   每次推送到 GitHub `main` 分支時，Render 會自動偵測並重新建置 Docker Image 進行佈署。


---

## 本地安裝與執行 (Local Development)

若要在本地端執行本專案，照以下步驟：

1. **Clone 專案**
```bash
   git clone [https://github.com/organicguava/task-management-system.git](https://github.com/organicguava/task-management-system.git)
   cd task-management-system

```

2. 安裝套件  

```bash
bundle install
```

3. 資料庫設定
```bash
# 確保已安裝 PostgreSQL
rails db:create
rails db:migrate
```

4. 啟動伺服器
```bash
bin/dev
# 或是 rails server
```