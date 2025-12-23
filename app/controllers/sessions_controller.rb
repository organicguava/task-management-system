class SessionsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:new, :create]
  
  def new
    # 顯示登入表單
  end

  def create
    # 1. 透過 email 撈出使用者
    user = User.find_by(email: params[:email])
    
    # 2. 驗證密碼 (authenticate 是 bcrypt 提供的方法)
    if user && user.authenticate(params[:password])
      # 3. 寫入 Session
      session[:user_id] = user.id
      redirect_to root_path, notice: t("flash.auth.login")
    else
      # 4. 登入失敗
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