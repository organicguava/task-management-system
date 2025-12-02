require 'rails_helper'

RSpec.feature "Tasks", type: :feature do
  # 測試情境：建立任務
  scenario "建立一個新任務" do
    # 1. 前往新增任務頁面
    visit new_task_path # check point:check path name consistency

    save_and_open_page # 視覺化capybara測試時看到的東西

    # 2. 填寫表單 
    # - fill_in '標籤上的文字' or 'name屬性', 
    # - Task.human_attribute_name,可以應付i18n,Rails 會自己去 zh-TW.yml 查 :title 對應的翻譯是什麼
    # - with: '輸入值'
    fill_in Task.human_attribute_name(:title), with: '買醬油'
    fill_in Task.human_attribute_name(:content), with: '要去全聯買'

    # 3. 送出表單 (按鈕上的文字)
    click_button '提交'

    # 4. 預期結果：畫面上應該要有剛剛輸入的標題，並且有 Flash 訊息
    expect(page).to have_content '買醬油'
    expect(page).to have_content '任務已成功建立' # #check point:flash content consistency
  end


  # 當visit edit_task_path(task) 時，會先建立資料
  let(:task) { FactoryBot.create(:task) }

  scenario "修改任務" do
    visit edit_task_path(task)

    fill_in Task.human_attribute_name(:title),with: '買醬油 (改)'

    click_button '更新任務'

    expect(page).to have_content '任務更新成功'
    expect(page).to have_content '買醬油 (改)'
  end

  context "當任務存在時 (測試刪除功能)" do
      # 1. Setup 寫在 context (群組) 層級
      let!(:task) { FactoryBot.create(:task, title: '要被刪掉的任務') }
      before { visit tasks_path }

      # 2. 範例 A: 驗證資料存在
      it "列表頁應顯示該任務" do
        expect(page).to have_content '要被刪掉的任務'
      end

      # 3. 範例 B: 測試點擊刪除
      context "當點擊刪除連結時" do
        before { click_link '刪除' } # 假設你的按鈕文字是 '刪除'

        it "應顯示成功訊息" do
          expect(page).to have_content '資料已刪除' # 確保 Flash 訊息正確
        end

        it "列表頁應不再顯示該任務" do
          expect(page).not_to have_content '要被刪掉的任務'
        end
      end
  end
end
