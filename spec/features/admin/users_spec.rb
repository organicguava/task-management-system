# encoding: utf-8

require 'rails_helper'

RSpec.describe "Admin::Users", type: :feature do
  subject { page }

  # 建立測試使用者（管理員）
  let(:admin) { create(:user, :admin, name: "Admin", email: "admin@example.com") }

  # 全域設定：所有測試開始前，先登入
  before { sign_in(admin) }

  # --- 測試情境：使用者列表 ---
  describe "使用者列表" do
    let!(:user1) { create(:user) }
    let!(:user2) { create(:user) }

    before { visit admin_users_path }

    it { is_expected.to have_content user1.name }
    it { is_expected.to have_content user2.name }
    it { is_expected.to have_content user1.email }
    it { is_expected.to have_content user2.email }

    context "顯示任務數量" do
      let!(:task1) { create(:task, user: user1) }
      let!(:task2) { create(:task, user: user1) }
      let!(:task3) { create(:task, user: user2) }

      before { visit admin_users_path }

      it "顯示 User One 有 2 筆任務" do
        within find('tr', text: user1.name) do
          expect(page).to have_content "2"
        end
      end

      it "顯示 User Two 有 1 筆任務" do
        within find('tr', text: user2.name) do
          expect(page).to have_content "1"
        end
      end
    end
  end

  # --- 測試情境：搜尋使用者 ---
  describe "搜尋使用者" do
    let!(:user_john) { create(:user, name: "John", email: "john@example.com") }
    let!(:user_jane) { create(:user, name: "Jane", email: "jane@test.com") }

    before { visit admin_users_path }

    context "以 Email 搜尋", js: true do
      before do
        fill_in "q_email_cont", with: "example\n"
      end

      it { is_expected.to have_content "john@example.com" }
      it { is_expected.not_to have_content "jane@test.com" }
    end
  end

  # --- 測試情境：新增使用者 ---
  describe "新增使用者" do
    before do
      visit new_admin_user_path

      fill_in User.human_attribute_name(:name), with: "New User"
      fill_in User.human_attribute_name(:email), with: "newuser@example.com"
      # 使用 id 定位，因為add user page 的提示字有"密碼"，會造成 Ambiguous match
      fill_in "user_password", with: "password123"
      fill_in "user_password_confirmation", with: "password123"

      click_button I18n.t("admin.users.form.submit")
    end

    it { is_expected.to have_current_path admin_users_path }
    it { is_expected.to have_content I18n.t("flash.common.create.notice") }
    it { is_expected.to have_content "New User" }
  end

  # --- 測試情境：編輯使用者 ---
  describe "編輯使用者" do
    let!(:target_user) { create(:user, name: "Original Name") }

    before do
      visit edit_admin_user_path(target_user)

      fill_in User.human_attribute_name(:name), with: "Updated Name"

      click_button I18n.t("admin.users.form.update")
    end

    it { is_expected.to have_current_path admin_users_path }
    it { is_expected.to have_content I18n.t("flash.common.update.notice") }
    it { is_expected.to have_content "Updated Name" }
    it { is_expected.not_to have_content "Original Name" }
  end

  # --- 測試情境：刪除使用者 ---
  describe "刪除使用者", js: true do
    let!(:target_user) { create(:user) }

    before { visit admin_users_path }

    it { is_expected.to have_content target_user.name }

    context "點擊刪除按鈕後" do
      before do
        within find('tr', text: target_user.name) do
          accept_confirm do
            find("a[data-turbo-method='delete']").click
          end
        end
      end

      it { is_expected.to have_content I18n.t("flash.common.destroy.notice") }
      it { is_expected.not_to have_content target_user.name }
    end
  end

  # --- 測試情境：查看使用者的任務列表 ---
  describe "查看使用者的任務列表" do
    let!(:target_user) { create(:user) }
    let!(:task1) { create(:task, user: target_user) }
    let!(:task2) { create(:task, user: target_user) }
    let!(:other_task) { create(:task, user: admin) }

    before do
      visit admin_users_path

      # 點擊查看任務按鈕（眼睛圖示）
      within find('tr', text: target_user.name) do
        find("a[href='#{admin_user_tasks_path(target_user)}']").click
      end
    end

    it { is_expected.to have_current_path admin_user_tasks_path(target_user) }

    # Navbar 應顯示該使用者的 email
    it { is_expected.to have_content target_user.email }

    # 應顯示該使用者的任務
    it { is_expected.to have_content task1.title }
    it { is_expected.to have_content task2.title }

    # 不應顯示其他使用者的任務
    it { is_expected.not_to have_content other_task.title }
  end

  # --- 測試情境：排序功能 ---
  describe "排序功能" do
    let!(:user_old) { create(:user, name: "Old User", created_at: 2.days.ago) }
    let!(:user_new) { create(:user, name: "New User", created_at: 1.hour.ago) }

    context "預設依建立時間倒序" do
      before { visit admin_users_path }

      it { is_expected.to have_content(/New User.*Old User/m) }
    end

    context "依任務數排序" do
      let!(:tasks_for_old_user) { create_list(:task, 3, user: user_old) }
      let!(:task_for_new_user) { create(:task, user: user_new) }

      before do
        visit admin_users_path
        # 點擊任務數排序
        within('thead') do
          click_link I18n.t('admin.users.index.tasks_count')
        end
      end

      # 升序：任務少的在前
      it { is_expected.to have_content(/New User.*Old User/m) }
    end
  end

  # 權限控制
  describe "權限控制" do
    context "當一般使用者嘗試存取管理頁面" do
      let(:normal_user) { create(:user, admin: false) }

      before do
        sign_out
        sign_in(normal_user)
        visit admin_users_path
      end


      it { is_expected.to have_current_path root_path }
    end

    context "當管理員存取管理頁面" do
      # admin 已在最上方定義，且 before 中已登入
      before { visit admin_users_path }

      it { is_expected.to have_current_path admin_users_path }
    end
  end

  describe "刪除最後一位管理員", js: true do
    # 確保 admin 是唯一的管理員
    before do
      # 清除其他可能存在的管理員，只保留 admin
      User.where(admin: true).where.not(id: admin.id).destroy_all
      visit admin_users_path
    end

    context "當嘗試刪除最後一位管理員" do
      before do
        within find('tr', text: admin.name) do
          accept_confirm do
            find("a[data-turbo-method='delete']").click
          end
        end
      end

      it { is_expected.to have_content I18n.t("activerecord.errors.models.user.attributes.base.last_admin") }
      it { is_expected.to have_content admin.name }
    end
  end
end
