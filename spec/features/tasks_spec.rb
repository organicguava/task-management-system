require 'rails_helper'

RSpec.describe "Tasks", type: :feature do
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


  # 測試群組 1: 驗證「排序功能」
  # 核心需求：資料庫必須乾淨，不能有分頁干擾 (資料 < 10筆)
  describe "任務排序 (Sorting)" do
    # 每次進來這個 context，先把所有任務刪光，確保是在第一頁
    before do
      Task.delete_all
    end

    let!(:task_early) { Task.create(title: "舊任務", end_time: 1.day.from_now, created_at: 1.day.ago) }
    let!(:task_late)  { Task.create(title: "新任務", end_time: 1.day.ago, created_at: Time.now) }

    context "列表預設依建立時間排序" do
      before { visit tasks_path }

      subject { page }

      it { is_expected.to have_content(/新任務.*舊任務/m) }
    end

    context "點擊結束時間排序" do
      before do
        visit tasks_path
        click_link Task.human_attribute_name(:end_time)
      end

      subject { page }

      # 點擊一次後是升序 (end_time 早的在前)
      # task_late 的 end_time 是 1.day.ago (早)，task_early 的是 1.day.from_now (晚)
      # 所以預期順序是：新任務 (task_late) 在前，舊任務 (task_early) 在後
      it { is_expected.to have_content(/舊任務.*新任務/m) }
    end
  end

  # 測試群組 2: 驗證「分頁功能」
  # 核心需求：資料 > 10筆
  describe "分頁功能 (Pagination)" do
    before(:all) do
      # 使用 before(:all) 避免每個 it 都重新清理和建立資料
      # 在所有測試前清理一次，最後用 after(:all) 清理
      Task.delete_all
      11.times { |n| Task.create!(title: "分頁測試任務 #{n}", status: 0, priority: 0) }
    end

    after(:all) do
      Task.delete_all
    end

    context "超過 10 筆資料時" do
      before do
        visit tasks_path
      end

      subject { page }

      # 第一頁顯示最新的 10 筆 (任務 10 ~ 任務 1)
      it { is_expected.to have_content("分頁測試任務 10") }

      # 第一頁不應該看到最舊的 (任務 0)
      it { is_expected.not_to have_content("分頁測試任務 0") }

      it { is_expected.to have_selector('.pagy-container') }
    end

    context "點擊下一頁後" do
      before do
        visit tasks_path
        click_link "2" # 點擊第 2 頁按鈕
      end

      subject { page }

      it { is_expected.to have_current_path(/page=2/) }
      it { is_expected.to have_content("分頁測試任務 0") }
    end
  end

  # 測試群組 3: 驗證「搜尋功能」
  # 核心需求：資料庫有特定特徵的資料
  describe "搜尋功能 (Search)" do
    before do
      Task.delete_all
      Task.create(title: "買蘋果", status: :pending)
      Task.create(title: "買香蕉", status: :completed)
    end

    context "依標題搜尋" do
      before do
        visit tasks_path
        fill_in "q[title_cont]", with: "蘋果"
        click_button I18n.t('common.search') # 或 "搜尋"
      end

      subject { page }

      it { is_expected.to have_content("買蘋果") }
      it { is_expected.not_to have_content("買香蕉") }
    end
  end
end
