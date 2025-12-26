class Admin::UsersController < Admin::BaseController
  # 將重複的程式碼抽出來，放到 private method 裡
  before_action :set_user, only: %i[edit update destroy]

  def index
    # 使用 Counter Cache，不再需要 JOIN 和 COUNT
    # tasks_count 欄位已經存在於 users 表中，直接查詢即可
    @q = User.ransack(params.fetch(:q, {}).reverse_merge(s: "created_at desc"))
    @pagy, @users = pagy(@q.result, limit: 10, overflow: :last_page)
  end

  def new
    @user = User.new
  end

  def create # 用來接收post(送)請求的
    @user = User.new(user_params)    
    
    if @user.save
      redirect_to admin_users_path, notice: t("flash.common.create.notice")


    else
      # 驗證失敗時，重新渲染 new 頁面（停留在表單）
      flash.now[:alert] = t("flash.admin.users.create.alert")
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    
    # 如果密碼欄位為空，不更新密碼
    if user_params[:password].blank?
      update_params = user_params.except(:password, :password_confirmation)
    else
      update_params = user_params
    end

    # 嘗試更新 (使用 Strong Parameters)
    if @user.update(update_params)
      # 成功：設定 Flash 訊息並轉跳回列表
      redirect_to admin_users_path, notice: t("flash.common.update.notice")
    else
      # 驗證失敗時停留在 edit 頁面並顯示錯誤訊息
      flash.now[:alert] = t("flash.admin.users.update.alert")
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    # 如果找不到 id，Rails 會自動跳 404，這行以下都不會執行
    @user.destroy
    redirect_to admin_users_path, status: :see_other, notice: t("flash.common.destroy.notice")
    # 必須回傳 HTTP 303 (See Other) 狀態碼，否則 Turbo 有時候會報錯。
  end

  private # 為了安全性，必須使用 Strong Parameters

  # edit update destroy 都有此動作，提取出來成為共用方法
  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
