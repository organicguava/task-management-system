# encoding: utf-8

require 'rails_helper'

RSpec.describe "Admin::Tasks", type: :request do
  let(:admin) { create(:user) }
  let(:target_user) { create(:user) }

  # 模擬登入
  before do
    post login_path, params: { user: { email: admin.email, password: "123456" } }
  end

  describe "GET /admin/users/:user_id/tasks" do
    let!(:target_tasks) { create_list(:task, 3, user: target_user) }
    let!(:admin_tasks) { create_list(:task, 2, user: admin) }

    it "成功回應" do
      get admin_user_tasks_path(target_user)
      expect(response).to have_http_status(:success)
    end

    it "只顯示該使用者的任務" do
      get admin_user_tasks_path(target_user)

      # 應包含目標使用者的任務
      target_tasks.each do |task|
        expect(response.body).to include(task.title)
      end

      # 不應包含管理員的任務
      admin_tasks.each do |task|
        expect(response.body).not_to include(task.title)
      end
    end

    it "回應包含目標使用者的 email" do
      get admin_user_tasks_path(target_user)
      expect(response.body).to include(target_user.email)
    end
  end

  describe "未登入時" do
    before do
      delete logout_path  # 先登出
    end

    it "重導向到登入頁面" do
      get admin_user_tasks_path(target_user)
      expect(response).to redirect_to(login_path)
    end
  end
end
