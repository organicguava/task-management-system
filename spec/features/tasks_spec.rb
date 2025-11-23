require 'rails_helper'

RSpec.feature "Tasks", type: :feature do
  # 測試情境：建立任務
  scenario "建立一個新任務" do
    # 1. 前往新增任務頁面 
    visit new_task_path #check point:check path name consistency

    save_and_open_page #視覺化capybara測試時看到的東西

    # 2. 填寫表單 (fill_in '標籤上的文字' or 'name屬性', with: '輸入值')
    fill_in 'Title', with: '買醬油' 
    fill_in 'Content', with: '要去全聯買'

    # 3. 送出表單 (按鈕上的文字)
    click_button '提交'

    # 4. 預期結果：畫面上應該要有剛剛輸入的標題，並且有 Flash 訊息
    expect(page).to have_content '買醬油'
    expect(page).to have_content '任務已成功建立' # #check point:flash content consistency
  end



  scenario "修改任務" do
  # 因為測edit 所以先建立資料
    task = FactoryBot.create(:task)
    
    visit edit_task_path(task) 
    
    fill_in 'Title', with: '買醬油 (改)' 
    
    click_button '更新任務' 

    expect(page).to have_content '任務更新成功' 
    expect(page).to have_content '買醬油 (改)'

  end

  scenario "刪除任務" do
    #因為測delete所以先建立資料
    task = FactoryBot.create(:task, title: '要被刪掉的任務')
    
    visit tasks_path 
    
    #確保刪除前看得到它
    expect(page).to have_content '要被刪掉的任務'
    
    # 4. Act: 按下刪除 (注意：Rails 7 預設刪除通常是按鈕而非連結)
    # 如果你的刪除是連結，改用 click_link '刪除'
    click_link '刪除' 

    expect(page).to have_content '資料已刪除' 
    
    #驗證該任務文字「不」存在於頁面上
    expect(page).not_to have_content '要被刪掉的任務'
end


end