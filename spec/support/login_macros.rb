module LoginMacros
  def sign_in(user)
    visit login_path
    fill_in User.human_attribute_name(:email), with: user.email
    fill_in User.human_attribute_name(:password), with: user.password

    # 此行用意為："等" Stimulus controller 跑完驗證並移除 disabled 屬性, 避免測試過快點擊到還沒啟用的按鈕
    expect(page).to have_button(I18n.t("sessions.new.submit"), disabled: false)
    
    # 安全點擊
    click_button I18n.t("sessions.new.submit")
  end

  def sign_out
    find('[data-testid="user-menu-btn"]').click
    find('[data-testid="logout-btn"]').click
  end
end