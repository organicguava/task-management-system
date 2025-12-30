module LoginMacros
  # Factory 中定義的固定密碼，避免依賴 user.password（has_secure_password 會清空明碼）
  DEFAULT_PASSWORD = "123456".freeze

  def sign_in(user, password: DEFAULT_PASSWORD)
    visit login_path
    fill_in User.human_attribute_name(:email), with: user.email
    fill_in User.human_attribute_name(:password), with: password

    click_button I18n.t("sessions.new.submit")
    expect(page).to have_content(I18n.t("flash.auth.login"))
  end

  # 提供可指定帳密的登入流程，用於測試錯誤情境
  def sign_in_with(email:, password:)
    visit login_path
    fill_in User.human_attribute_name(:email), with: email
    fill_in User.human_attribute_name(:password), with: password


    click_button I18n.t("sessions.new.submit")
  end

  def sign_out
    find('[data-testid="user-menu-btn"]').click
    find('[data-testid="logout-btn"]').click
    # 點擊後，必須等待頁面出現「登出成功」的訊息，才能讓方法結束。
    expect(page).to have_content(I18n.t("flash.auth.logout"))
  end
end
