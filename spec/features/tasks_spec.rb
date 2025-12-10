require 'rails_helper'

RSpec.feature "Tasks", type: :feature do
  # --- 測試情境：建立任務 ---
  scenario "建立一個新任務" do
    visit new_task_path

    # 填寫表單
    fill_in Task.human_attribute_name(:title), with: '買醬油'
    fill_in Task.human_attribute_name(:content), with: '要去全聯買'

    # 選擇狀態 (假設預設是待處理，若需測試下拉選單可在此加入)

    click_button I18n.t('tasks.form.submit')

    # 驗證
    expect(page).to have_content '買醬油'
    # 建議使用 I18n key 來驗證 flash 訊息，比較穩固
    expect(page).to have_content I18n.t('flash.tasks.create.notice')
  end

  # --- 測試情境：修改任務 ---
  scenario "修改任務" do
    # 這裡的 task 只會在這個 scenario 被建立
    task = create(:task)
    visit edit_task_path(task)

    fill_in Task.human_attribute_name(:title), with: '買醬油 (改)'

    # 假設 update 按鈕的 I18n路徑
    click_button I18n.t('tasks.form.update')
    expect(page).to have_content I18n.t('flash.tasks.update.notice')
    expect(page).to have_content '買醬油 (改)'
  end

  # --- 測試情境：刪除任務 ---
  context "當任務存在時" do
    let!(:task) { create(:task, title: '要被刪掉的任務') }

    before { visit tasks_path }

    it "列表頁應顯示該任務" do
      expect(page).to have_content '要被刪掉的任務'
    end

    context "點擊刪除按鈕時" do
      before do
        # 限定範圍，避免點到別人的刪除按鈕
        within find('tr', text: task.title) do
          click_link I18n.t('action.delete')
        end
      end

      it "列表頁應不再顯示該任務" do
        # 驗證 flash
        expect(page).to have_content I18n.t('flash.tasks.destroy.notice')
        # 驗證資料消失
        expect(page).not_to have_content '要被刪掉的任務'
      end
    end
  end

  # --- 測試情境：搜尋與過濾 ---
  describe "搜尋與過濾功能" do
    # 只在這個區塊內建立這些測試資料，不影響其他測試
    let!(:task_pending) { create(:task, title: "買牛奶", status: :pending) }
    let!(:task_completed) { create(:task, title: "寫作業", status: :completed) }

    before { visit tasks_path }

    context "搜尋特定標題時" do
      before do
        fill_in Task.human_attribute_name(:title), with: "牛奶"
        click_button I18n.t('common.search', default: '搜尋')
      end

      it "顯示符合關鍵字的任務" do
        expect(page).to have_content "買牛奶"
      end

      it "不顯示不符合關鍵字的任務" do
        expect(page).not_to have_content "寫作業"
      end
    end

    context "篩選特定狀態時" do
      before do
        # 從下拉選單選擇 (使用 Model 翻譯)
        select I18n.t('activerecord.enums.task.status.pending'), from: Task.human_attribute_name(:status)
        click_button I18n.t('common.search', default: '搜尋')
      end

      it "顯示該狀態的任務" do
        expect(page).to have_content "買牛奶"
      end

      it "不顯示其他狀態的任務" do
        expect(page).not_to have_content "寫作業"
      end
    end
  end

  # --- 測試情境：列表頁面排序 (整合 Created_at 與 End_time) ---
  describe "列表頁面排序" do
    context "預設排序 (建立時間)" do
      let!(:old_task) { create(:task, title: "舊的任務", created_at: 1.day.ago) }
      let!(:new_task) { create(:task, title: "新的任務", created_at: Time.zone.now) }

      before { visit tasks_path }

      it "任務應依照建立時間倒序排列（新的在上面）" do
        expect(page.body).to match(/#{new_task.title}.*#{old_task.title}/m)
      end
    end

    context "點擊結束時間排序時" do
      let!(:task_early) { create(:task, title: "早結束的任務", end_time: 1.day.from_now) }
      let!(:task_late) { create(:task, title: "晚結束的任務", end_time: 3.days.from_now) }

      before { visit tasks_path }

      it "任務應依照結束時間降冪排列" do
        # 1. 點開下拉選單
        find('summary', text: '排序方式').click

        # 2. 點擊連結 (使用 within 鎖定範圍)
        within 'details' do
          click_link Task.human_attribute_name(:end_time)
        end

        # 3. 驗證晚結束的在前面
        expect(page.body.index(task_late.title)).to be < page.body.index(task_early.title)
      end
    end
  end
end
