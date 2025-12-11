require 'rails_helper'

RSpec.feature "Tasks", type: :feature do
  # --- 測試情境：建立任務 ---
  
  scenario "任務能被成功建立" do
    visit new_task_path

    fill_in Task.human_attribute_name(:title), with: '買醬油'
    fill_in Task.human_attribute_name(:content), with: '要去全聯買'

    click_button I18n.t('tasks.form.submit')

    # 驗證
    
    expect(page).to have_content '買醬油'
    expect(page).to have_content I18n.t('flash.tasks.create.notice')
  end

  # --- 測試情境：修改任務 ---
  scenario "任務能被成功修改" do
    task = create(:task)
    visit edit_task_path(task)

    fill_in Task.human_attribute_name(:title), with: '買醬油 (改)'

    click_button I18n.t('tasks.form.update')
    
    expect(page).to have_content I18n.t('flash.tasks.update.notice')
    expect(page).to have_content '買醬油 (改)'
  end

  # --- 測試情境：刪除任務 ---
  context "當任務存在時" do
    let!(:task) { create(:task, title: '要被刪掉的任務') }

    before { visit tasks_path }

    
    it "該任務應顯示於列表頁" do
      expect(page).to have_content '要被刪掉的任務'
    end

    context "點擊刪除按鈕後" do
      before do
        within find('tr', text: task.title) do
          click_link I18n.t('action.delete')
        end
      end

      it "該任務應從列表頁消失" do
        expect(page).to have_content I18n.t('flash.tasks.destroy.notice')
        expect(page).not_to have_content '要被刪掉的任務'
      end
    end
  end

  # --- 測試情境：搜尋與過濾 ---
  describe "搜尋與過濾功能" do
    let!(:task_pending) { create(:task, title: "買牛奶", status: :pending) }
    let!(:task_completed) { create(:task, title: "寫作業", status: :completed) }

    before { visit tasks_path }

    context "進行標題搜尋時" do
      before do
        fill_in Task.human_attribute_name(:title), with: "牛奶"
        click_button I18n.t('common.search', default: '搜尋')
      end

      
      it "符合關鍵字的任務應被顯示" do
        expect(page).to have_content "買牛奶"
      end

      it "不符合關鍵字的任務不應被顯示" do
        expect(page).not_to have_content "寫作業"
      end
    end

    context "進行狀態篩選時" do
      before do
        select I18n.t('activerecord.enums.task.status.pending'), from: Task.human_attribute_name(:status)
        click_button I18n.t('common.search', default: '搜尋')
      end

      it "該狀態的任務應被顯示" do
        expect(page).to have_content "買牛奶"
      end

      it "其他狀態的任務不應被顯示" do
        expect(page).not_to have_content "寫作業"
      end
    end
  end

  # --- 測試情境：列表頁面排序 ---
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
        find('summary', text: '排序方式').click

        within 'details' do
          click_link Task.human_attribute_name(:end_time)
        end

        expect(page.body.index(task_late.title)).to be < page.body.index(task_early.title)
      end
    end
  end
end