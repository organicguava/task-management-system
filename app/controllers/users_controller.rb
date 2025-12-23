class UsersController < ApplicationController
  skip_before_action :authenticate_user!, only: [:new, :create]
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    
    if @user.save
      # 註冊成功後，直接幫他登入 (將 ID 存入 Session)
      session[:user_id] = @user.id
      redirect_to root_path, notice: t("flash.users.create.notice")
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params # rails 安全機制：Strong Parameters
    # 記得要在這裡允許 password 和 password_confirmation
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end