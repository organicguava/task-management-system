# encoding: utf-8

require 'rails_helper'

RSpec.describe "Tasks", type: :feature do
  subject { page }

  # --- 測試情境：建立任務 ---
  describe "建立任務" do
    before do
      visit new_task_path

      # 填寫標題與內容
      fill_in Task.human_attribute_name(:title), with: '買醬油'
      fill_in Task.human_attribute_name(:content), with: '要去全聯買'

      # 拉選單有 prompt: "Select" 且 Model 驗證必填，必須選擇
      select I18n.t('activerecord.enums.task.status.pending'), from: Task.human_attribute_name(:status)
      select I18n.t('activerecord.enums.task.priority.low'), from: Task.human_attribute_name(:priority)

      click_button I18n.t('tasks.form.submit')
    end

    it { is_expected.to have_content '買醬油' }
    it { is_expected.to have_content I18n.t('flash.tasks.create.notice') }
  end

  # --- 測試情境：修改任務 ---
  describe "修改任務" do
    let(:task) { create(:task) }

    before do
      # 為了確保測試獨立性，這裡直接 visit 編輯頁面是合規的
      # 若要測試從列表點擊進入，之後另開一個 context
      visit edit_task_path(task)

      fill_in Task.human_attribute_name(:title), with: '買醬油 (改)'
      click_button I18n.t('tasks.form.update')
    end

    it { is_expected.to have_content I18n.t('flash.tasks.update.notice') }
    it { is_expected.to have_content '買醬油 (改)' }
  end

  # --- 測試情境：刪除任務 ---
  # 加入 js: true 以支援 Turbo 的 confirm dialog 與 delete method
  describe "刪除任務", js: true do
    let!(:task) { create(:task, title: '要被刪掉的任務') }

    context "當任務存在時" do
      before { visit tasks_path }

      it { is_expected.to have_content '要被刪掉的任務' }

      context "點擊刪除按鈕後" do
        before do
          # --- debug 用---
          puts "Current Locale: #{I18n.locale}"
          puts "Translate Delete: '#{I18n.t('action.delete')}'"
          puts "Task Title: '#{task.title}'"
          # -----------------------
          within find('tr', text: task.title) do # 使用 within 鎖定特定任務的列 (Row)，避免點到別人的刪除按鈕
            accept_confirm do
              find("a[title='刪除']").click # 先暫時寫死，測試用
            end
          end
        end

        it { is_expected.to have_content I18n.t('flash.tasks.destroy.notice') }
        it { is_expected.not_to have_content '要被刪掉的任務' }
      end
    end
  end

  # --- 測試群組 1: 驗證「排序功能」 ---
  describe "任務排序 (Sorting)" do
    # 建立不同時間點的任務
    let!(:task_early) { create(:task, title: "舊任務", end_time: 1.day.from_now, created_at: 1.day.ago) }
    let!(:task_late)  { create(:task, title: "新任務", end_time: 1.day.ago, created_at: Time.now) }

    context "列表預設依建立時間排序" do
      before { visit tasks_path }

      # 預期：新任務 (Created Now) 在前，舊任務 (Created 1 day ago) 在後
      it { is_expected.to have_content(/新任務.*舊任務/m) }
    end

    context "點擊結束時間排序" do
      before do
        visit tasks_path
        # 點擊表頭排序連結 , 使用 within 告訴 Capybara 只點擊「表格標頭 (thead)」裡的那個連結，避免點到其他地方的同名連結
        within('thead') do
          click_link Task.human_attribute_name(:end_time)
        end
      end

      # 預期升序：結束時間早的 (task_late: 1.day.ago) 在前，晚的 (task_early: 1.day.from_now) 在後
      it { is_expected.to have_content(/新任務.*舊任務/m) }
    end
  end

  # --- 測試群組 2: 驗證「分頁功能」 ---
  describe "分頁功能 (Pagination)" do
    before do
      # 建立 21 筆任務以觸發分頁 (Pagy 預設 10 筆)
      create_list(:task, 21, title: "分頁測試任務")
    end

    context "在第一頁時" do
      before { visit tasks_path }

      it { is_expected.to have_selector('.pagy-container') }
      it { is_expected.to have_content("分頁測試任務", count: 10) }
    end

    context "點擊下一頁後" do
      before do
        visit tasks_path
        # 因為使用了 Inline CSS/SVG，確保能點擊到連結
        within(".pagy-container") do
          click_link "2"
        end
      end

      it { is_expected.to have_current_path(/page=2/) }
      it { is_expected.to have_content("分頁測試任務") }
    end
  end

  # --- 測試群組 3: 驗證「搜尋功能」 ---
  # 加入 js: true 以支援 Autosubmit Controller 或模擬鍵盤輸入
  describe "搜尋功能 (Search)", js: true do
    before do
      create(:task, title: "買蘋果", status: :pending)
      create(:task, title: "買香蕉", status: :completed)
      visit tasks_path
    end

    context "依標題搜尋" do
      before do
        # 模擬輸入並按下 Enter 鍵，使用更新後的 i18n placeholder
        fill_in I18n.t('tasks.index.search'), with: "蘋果\n"
      end

      it { is_expected.to have_content("買蘋果") }
      it { is_expected.not_to have_content("買香蕉") }
    end
  end
end
