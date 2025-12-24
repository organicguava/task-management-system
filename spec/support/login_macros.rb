module LoginMacros
  def sign_in(user)
    visit login_path
    fill_in User.human_attribute_name(:email), with: user.email
    fill_in User.human_attribute_name(:password), with: user.password

    # 此行用意為："等" Stimulus controller 跑完驗證並移除 disabled 屬性, 避免測試過快點擊到還沒啟用的按鈕
    # expect(page).to have_button(I18n.t("sessions.new.submit"), disabled: false)

    # 安全點擊
    click_button I18n.t("sessions.new.submit")
    expect(page).to have_content(I18n.t("flash.auth.login"))
  end

  # 提供可指定帳密的登入流程，用於測試錯誤情境
  def sign_in_with(email:, password:)
    visit login_path
    fill_in User.human_attribute_name(:email), with: email
    fill_in User.human_attribute_name(:password), with: password


    click_button I18n.t("sessions.new.submit")
    # 等待按鈕啟用 (確認 JS 有跑)
    # expect(page).to have_button(submit_btn, disabled: false)


    # 點擊後，必須等待頁面出現「登入成功」的訊息，才能讓方法結束。
    # 這能防止測試程式在登入完成前就急著跳轉頁面 (visit ...)。
    # expect(page).to have_content(I18n.t("flash.auth.login"))
  end

  def sign_out
    find('[data-testid="user-menu-btn"]').click
    find('[data-testid="logout-btn"]').click
    # 點擊後，必須等待頁面出現「登出成功」的訊息，才能讓方法結束。
    expect(page).to have_content(I18n.t("flash.auth.logout"))
  end
end
