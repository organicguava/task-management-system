class TasksController < ApplicationController
  # 將重複的程式碼抽出來，放到 private method 裡
  before_action :set_task, only: %i[edit update destroy]


=begin
    已用ransack重構
    @tasks = Task.all
                  .search_by_title(params[:q])
                  .search_by_status(params[:status])
                  .search_by_priority(params[:priority])
                  .controller_index_query(params[:sort_by], params[:direction])
=end
  def index
    # 加入 .includes(:user), 避免 N+1 查詢問題
    # 使用 reverse_merge 設定預設排序為「建立時間倒序」，避免每次都要在 view 傳參數
    @q = current_user.tasks.includes(:user).ransack(params.fetch(:q, {}).reverse_merge(s: "created_at desc"))
    # 取得初步結果，distinct: true 可以避免關聯查詢時出現重複資料
    # 先查詢結果 -> 再分頁
    @pagy, @tasks = pagy(@q.result(distinct: true), limit: 10, overflow: :last_page)
  end

  def new
    @task = Task.new
  end

  def create # 用來接收post(送)請求的
    @task = current_user.tasks.build(task_params)

    if @task.save
      redirect_to tasks_path, notice: t("flash.common.create.notice")
      # 將兩行合併為以上一行
      # flash[:notice] = t("flash.tasks.create.notice")
      # redirect_to tasks_path # 成功後轉跳回列表頁

    else
      # 驗證失敗時，重新渲染 new 頁面（停留在表單）
      flash.now[:alert] = t("flash.tasks.create.alert")
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    # 嘗試更新 (使用 Strong Parameters)
    if @task.update(task_params)
      # 成功：設定 Flash 訊息並轉跳回列表
      redirect_to tasks_path, notice: t("flash.common.update.notice")
    else
      # 驗證失敗時停留在 edit 頁面並顯示錯誤訊息
      flash.now[:alert] = t("flash.tasks.update.alert")
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    # 如果找不到 id，Rails 會自動跳 404，這行以下都不會執行
    @task.destroy
    redirect_back_or_to tasks_path, status: :see_other, notice: t("flash.common.destroy.notice")
    # 必須回傳 HTTP 303 (See Other) 狀態碼，否則 Turbo 有時候會報錯。
  end

  private # 為了安全性，必須使用 Strong Parameters

  # edit update destroy 都有此動作，提取出來成為共用方法
  def set_task
    @task = current_user.tasks.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:title, :content, :end_time, :status, :priority)
  end
end
