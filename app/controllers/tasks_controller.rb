class TasksController < ApplicationController
  # 將重複的程式碼抽出來，放到 private method 裡
  before_action :set_task, only: %i[edit update destroy]

  def index
    # 使用chain，像接力棒一樣把查詢條件串起來
    @tasks = Task.all
                  .search_by_title(params[:q])      # 搜尋標題
                  .search_by_status(params[:status]) # 搜尋狀態
                  .search_by_priority(params[:priority]) # 搜尋優先順序
                  .controller_index_query(params[:sort_by], params[:direction]) # filter 排序
    # 注意！直到 View 讀取 @tasks 時才會發送一次 SQL

    #  1. 篩選 (Filter) - 使用 Ransack, 且搜尋後的結果進行分頁
    @q = Task.ransack(params[:q])

    #  2. 排序 (Sort) - 使用你 Model 裡自定義的 scope
    # @pagy 存放分頁資訊, @tasks 存放該頁的資料
    # 接住 Ransack 篩選後的結果 (@q.result)，再串接 controller_index_query（"NULLS LAST" 以及 "白名單檢查" 邏輯）
    sorted_tasks = @q.result.controller_index_query(params[:sort_by], params[:direction])

    # 3. 分頁 (Pagination) - 使用 Pagy
    # 最後將篩選並排序好的資料丟給 Pagy, 並在此直接設定每頁幾筆 (limit) 和溢位處理 (overflow)
    @pagy, @tasks = pagy(sorted_tasks, limit: 10, overflow: :last_page)
  end

  def new
    @task = Task.new
  end

  def create # 用來接收post(送)請求的
    @task = Task.new(task_params)

    if @task.save
      redirect_to tasks_path, notice: t("flash.tasks.create.notice")
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
      redirect_to tasks_path, notice: t("flash.tasks.update.notice")
    else
      # 驗證失敗時停留在 edit 頁面並顯示錯誤訊息
      flash.now[:alert] = t("flash.tasks.update.alert")
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    # 如果找不到 id，Rails 會自動跳 404，這行以下都不會執行
    @task.destroy
    redirect_to tasks_path, status: :see_other, notice: t("flash.tasks.destroy.notice")
    # 必須回傳 HTTP 303 (See Other) 狀態碼，否則 Turbo 有時候會報錯。
  end

  private # 為了安全性，必須使用 Strong Parameters

  # edit update destroy 都有此動作，提取出來成為共用方法
  def set_task
    @task = Task.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:title, :content, :end_time, :status, :priority)
  end
end
