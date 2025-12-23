# spec/features/authentication_spec.rb
require 'rails_helper'

RSpec.describe "Authentication", type: :feature, js: true do
  subject { page }

  # --- 測試情境：使用者註冊 ---
  describe "使用者註冊" do
    before do
      visit signup_path

      # 填寫註冊表單
      fill_in User.human_attribute_name(:name), with: "NewUser"
      fill_in User.human_attribute_name(:email), with: "new@example.com"
      fill_in User.human_attribute_name(:password), with: "password"
      fill_in User.human_attribute_name(:password_confirmation), with: "password"

      # Capybara 會在這裡自動重試幾秒鐘，直到按鈕解鎖或超時,避免測試過快點擊到還沒啟用的按鈕
      # expect(page).to have_button(I18n.t("users.new.submit"), disabled: false)

      click_button I18n.t("users.new.submit")
      if page.has_css?(".text-red-800")
         puts "\n========== ⚠️ 註冊失敗原因 ⚠️ =========="
         puts page.all(".text-red-800").map(&:text)
         puts "======================================\n"
      else
         puts "\n========== 📄 目前頁面文字 📄 =========="
         puts page.text
         puts "======================================\n"
      end
      save_and_open_page # launchy:debug
    end

    context "註冊成功" do
      it { is_expected.to have_current_path root_path }
      it { is_expected.to have_content "NewUser" }
      it { is_expected.to have_content I18n.t("flash.users.create.notice") }
    end
  end

  # --- 測試情境：使用者登入 ---
  describe "使用者登入" do
    let!(:user) { create(:user) }


    context "資料正確" do
      before do
        sign_in(user)
      end

      it { is_expected.to have_current_path root_path }
      it { is_expected.to have_content I18n.t("flash.auth.login") }
      it { is_expected.to have_content user.name }
    end

    context "資料錯誤" do
      before do
        sign_in_with(email: user.email, password: "wrongpassword")
      end
      it { is_expected.to have_content I18n.t("flash.auth.login_failed") }

      # 驗證 Email 是否有保留 (配合 Controller 的修正)
      it "保留原本輸入的 Email" do
        expect(page).to have_field(User.human_attribute_name(:email), with: user.email)
      end
    end
  end

  # --- 測試情境：使用者登出 ---
  describe "使用者登出" do
    let(:user) { create(:user) }

    before do
        # 使用helper:login_macros.rb 內的 method
        sign_in(user)
        sign_out
    end

    it { is_expected.to have_current_path login_path }
    it { is_expected.to have_content I18n.t("flash.auth.logout") }

    # 登出後，Navbar 應該不顯示使用者名稱
    it { is_expected.not_to have_content user.name }
  end

  # --- 測試情境：權限與資料範圍 ---
  describe "權限控管" do
    let(:user_a) { create(:user, name: "User A") }
    let(:user_b) { create(:user, name: "User B") }

    # 建立分別屬於不同人的任務
    let!(:task_a) { create(:task, user: user_a, title: "A的秘密任務") }
    let!(:task_b) { create(:task, user: user_b, title: "B的秘密任務") }

    context "未登入時" do
      before { visit tasks_path }

      # 應被導向登入頁面
      it { is_expected.to have_current_path login_path }
      it { is_expected.to have_content I18n.t("flash.auth.require_login") }
    end

    context "登入為 User A" do
      before do
        # 使用helper:login_macros.rb 內的 method
        sign_in(user_a)
        visit tasks_path
      end

      # 只能看到自己的任務
      it { is_expected.to have_content "A的秘密任務" }
      it { is_expected.not_to have_content "B的秘密任務" }
    end
  end
end
