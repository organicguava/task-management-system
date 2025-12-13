require 'rails_helper'

RSpec.feature "Tasks", type: :feature do
  # --- 測試情境：建立任務 ---
  describe "建立任務" do
    before do
      visit new_task_path
      fill_in Task.human_attribute_name(:title), with: '買醬油'
      fill_in Task.human_attribute_name(:content), with: '要去全聯買'
      click_button I18n.t('tasks.form.submit')
    end

    subject { page }

    it { is_expected.to have_content '買醬油' }
    it { is_expected.to have_content I18n.t('flash.tasks.create.notice') }
  end

  # --- 測試情境：修改任務 ---
  describe "修改任務" do
    let(:task) { create(:task) }

    before do
      visit edit_task_path(task)
      fill_in Task.human_attribute_name(:title), with: '買醬油 (改)'
      click_button I18n.t('tasks.form.update')
    end

    subject { page }

    it { is_expected.to have_content I18n.t('flash.tasks.update.notice') }
    it { is_expected.to have_content '買醬油 (改)' }
  end


  # --- 測試情境：刪除任務 ---
  describe "刪除任務" do
    let!(:task) { create(:task, title: '要被刪掉的任務') }

    context "當任務存在時" do
      before { visit tasks_path }

      subject { page }

      it { is_expected.to have_content '要被刪掉的任務' }

      context "點擊刪除按鈕後" do
        before do
          within find('tr', text: task.title) do
            click_link I18n.t('action.delete')
          end
        end

        it { is_expected.to have_content I18n.t('flash.tasks.destroy.notice') }
        it { is_expected.not_to have_content '要被刪掉的任務' }
      end
    end
  end


  # --- 測試情境：搜尋與過濾 ---
  describe "搜尋與過濾功能" do
    let!(:task_pending) { create(:task, title: "買牛奶", status: :pending) }
    let!(:task_completed) { create(:task, title: "寫作業", status: :completed, priority: :high) }
    let!(:task_medium) { create(:task, title: "中度優先級工作", status: :pending, priority: :medium) }

    before { visit tasks_path }

    context "進行標題搜尋時" do
      before do
        fill_in Task.human_attribute_name(:title), with: "牛奶"
        click_button I18n.t('common.search', default: '搜尋')
      end

      subject { page }

      it { is_expected.to have_content "買牛奶" }
      it { is_expected.not_to have_content "寫作業" }
    end

    context "進行狀態篩選時" do
      before do
        select I18n.t('activerecord.enums.task.status.pending'), from: Task.human_attribute_name(:status)
        click_button I18n.t('common.search', default: '搜尋')
      end

      subject { page }

      it { is_expected.to have_content "買牛奶" }
      it { is_expected.not_to have_content "寫作業" }
    end
  end


  # --- 測試情境：列表頁面排序 ---
  describe "列表頁面排序" do
    context "預設排序 (建立時間)" do
      let!(:old_task) { create(:task, title: "舊的任務", created_at: 1.day.ago) }
      let!(:new_task) { create(:task, title: "新的任務", created_at: Time.zone.now) }

      before { visit tasks_path }

      subject { page }

      it { is_expected.to have_content(/#{new_task.title}.*#{old_task.title}/m) }
    end

    context "點擊結束時間排序時" do
      let!(:task_early) { create(:task, title: "早結束的任務", end_time: 1.day.from_now) }
      let!(:task_late) { create(:task, title: "晚結束的任務", end_time: 3.days.from_now) }

      before do
        visit tasks_path
        find('summary', text: '排序方式').click
        within 'details' do
          click_link Task.human_attribute_name(:end_time)
        end
      end

      subject { page.body }

      it { is_expected.to match(/#{task_late.title}.*#{task_early.title}/m) }
    end

    context "依優先順序篩選時" do
      let!(:task_low) { create(:task, title: "低優先任務") }
      let!(:task_high) { create(:task, title: "高優先任務", priority: :high) }
      let!(:task_medium) { create(:task, title: "中度優先級工作", priority: :medium) }

      before do
        visit tasks_path
        find('summary', text: '排序方式').click
        if page.has_selector?('select[name="priority"]')
          select I18n.t('activerecord.enums.task.priority.low'), from: 'priority'
        else
          select I18n.t('activerecord.enums.task.priority.low'), from: Task.human_attribute_name(:priority)
        end
        click_button I18n.t('common.search', default: '搜尋')
      end

      subject { page }

      it { is_expected.to have_content task_low.title }
      it { is_expected.not_to have_content task_high.title }
      it { is_expected.not_to have_content task_medium.title }
    end
  end
end
