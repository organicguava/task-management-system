class SessionsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :new, :create ]

  def new
    # 顯示登入表單
  end

  def create
    # 使用 values_at 一次取出，並利用 safe navigation (&.) 避免 nil error
    email, password = params.require(:user).values_at(:email, :password)
    user = User.find_by(email: email)

    if user && user.authenticate(password)
      session[:user_id] = user.id
      redirect_to root_path, notice: t("flash.auth.login")
    else
      # 建立一個非持久化的 user 物件，僅為了回填表單用（登入失敗後可以顯示原本輸入的 Email）
      @user = User.new(email: email)
      flash.now[:alert] = t("flash.auth.login_failed")
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    # 將 User ID 從 Session 中移除(登出)
    session[:user_id] = nil
    redirect_to login_path, notice: t("flash.auth.logout")
  end
end
