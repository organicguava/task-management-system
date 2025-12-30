# encoding: utf-8

require 'rails_helper'

RSpec.describe "Admin::Tasks", type: :feature do
  subject { page }

  # 建立測試使用者（管理員）
  let(:admin) { create(:user, name: "Admin", email: "admin@example.com") }

  # 建立被查看任務的使用者
  let(:target_user) { create(:user, name: "Target User", email: "target@example.com") }

  # 全域設定：所有測試開始前，先登入
  before { sign_in(admin) }

  # --- 測試情境：查看使用者任務列表 ---
  describe "查看使用者任務列表" do
    let!(:task1) { create(:task, title: "Task Alpha", content: "Content A", user: target_user, priority: :high, status: :pending) }
    let!(:task2) { create(:task, title: "Task Beta", content: "Content B", user: target_user, priority: :low, status: :completed) }
    let!(:admin_task) { create(:task, title: "Admin Task", user: admin) }

    before { visit admin_user_tasks_path(target_user) }

    # Navbar 顯示被查看使用者的 Email
    it "Navbar 顯示被查看使用者的 Email" do
      within('nav') do
        expect(page).to have_content target_user.email
      end
    end

    # 顯示該使用者的任務
    it { is_expected.to have_content task1.title }
    it { is_expected.to have_content task2.title }

    # 不顯示其他使用者的任務
    it { is_expected.not_to have_content admin_task.title }
  end

  # --- 測試情境：返回按鈕 ---
  describe "返回按鈕" do
    before { visit admin_user_tasks_path(target_user) }

    it "點擊返回按鈕回到使用者列表" do
      # 找到返回按鈕並點擊
      find("a[href='#{admin_users_path}']", match: :first).click

      expect(page).to have_current_path admin_users_path
    end
  end

  # --- 測試情境：搜尋任務 ---
  describe "搜尋任務" do
    let!(:task_apple) { create(:task, title: "Buy Apple", user: target_user) }
    let!(:task_banana) { create(:task, title: "Buy Banana", user: target_user) }

    before { visit admin_user_tasks_path(target_user) }

    context "以標題搜尋", js: true do
      before do
        fill_in "q_title_cont", with: "Apple\n"
      end

      it { is_expected.to have_content "Buy Apple" }
      it { is_expected.not_to have_content "Buy Banana" }
    end
  end

  # --- 測試情境：排序功能 ---
  describe "排序功能" do
    let!(:task_old) { create(:task, title: "Old Task", user: target_user, created_at: 2.days.ago) }
    let!(:task_new) { create(:task, title: "New Task", user: target_user, created_at: 1.hour.ago) }

    context "預設依建立時間倒序" do
      before { visit admin_user_tasks_path(target_user) }

      it { is_expected.to have_content(/New Task.*Old Task/m) }
    end

    context "依優先級排序" do
      let!(:task_high) { create(:task, title: "High Priority", user: target_user, priority: :high) }
      let!(:task_low) { create(:task, title: "Low Priority", user: target_user, priority: :low) }

      before do
        visit admin_user_tasks_path(target_user)
        within('thead') do
          click_link Task.human_attribute_name(:priority)
        end
      end

      # 點擊後應該有排序效果（升序：low 在前）
      it { is_expected.to have_content(/Low Priority.*High Priority/m) }
    end
  end
end
