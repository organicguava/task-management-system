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
- 網址：(待補齊)
- Basic Auth 帳號：admin123 
- Basic Auth 密碼：666666

---  

edit it later ....  
This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
