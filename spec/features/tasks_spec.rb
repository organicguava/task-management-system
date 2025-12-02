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

  # 測試情境：修改任務
  # 當visit edit_task_path(task) 時，會先建立資料
  let(:task) { FactoryBot.create(:task) }

  scenario "修改任務" do
    visit edit_task_path(task)

    fill_in Task.human_attribute_name(:title), with: '買醬油 (改)'

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
        before do
          within find('tr', text: task.title) do # 限定該任務的刪除(不然一個頁面中會有好幾筆""刪除"連結)
            click_link I18n.t('action.delete') # 在 before 中需用 I18n.t() 而非 t()
          end
        end

        it "應顯示成功訊息" do
          expect(page).to have_content '資料已刪除' # 確保 Flash 訊息正確
        end

        it "列表頁應不再顯示該任務" do
          expect(page).not_to have_content '要被刪掉的任務'
        end
      end
  end

  # 測試情境：列表頁面排序
  # 用let! 讓資料在進入範例前就建立好
  let!(:old_task) { create(:task, title: "舊的任務", created_at: 1.day.ago) }
  let!(:new_task) { create(:task, title: "新的任務", created_at: Time.zone.now) }

  describe "列表頁面排序" do
    context "當使用者進入任務列表頁時" do
      before { visit tasks_path }

      scenario "任務應該依照建立時間倒序排列（新的在上面）" do
        # 表示先找到"新任務"，後面接著要在任何地方找到"舊任務"
        expect(page.body).to match(/#{new_task.title}.*#{old_task.title}/m)
      end
    end
  end
end
