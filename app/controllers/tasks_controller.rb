class TasksController < ApplicationController
  # 將重複的程式碼抽出來，放到 private method 裡
  before_action :set_task, only: %i[edit update destroy]

  def index
=begin
    已用ransack重構
    @tasks = Task.all
                  .search_by_title(params[:q])
                  .search_by_status(params[:status])
                  .search_by_priority(params[:priority])
                  .controller_index_query(params[:sort_by], params[:direction])
=end

    #  1. 篩選 (Filter) - 使用 Ransack, 且搜尋後的結果進行分頁
    # 使用 params.fetch(:q, {}) 確保即使沒有搜尋參數 (nil) 也能回傳空 Hash，避免報錯
    # 使用 reverse_merge 設定預設值：只有當 params 裡沒有 :s (排序) 時，才會使用 'created_at desc'
    @q = Task.ransack(params.fetch(:q, {}).reverse_merge(s: "created_at desc"))

    #  取得初步結果，distinct: true 可以避免關聯查詢時出現重複資料
    @tasks = @q.result(distinct: true)

    #  2. 排序 (Sort) - 使用你 Model 裡自定義的 scope
    # 這裡做一個相容性處理：
    # A. 如果是用舊的 Table Header 排序 (傳送 sort_by 和 direction 參數) -> 寫在tasks_helper的自定義scope
    if params[:sort_by].present?
      @tasks = @tasks.controller_index_query(params[:sort_by], params[:direction])

    #    B. 如果是用 Ransack 的下拉選單排序 (params[:q][:s]) -> Ransack 會在上面 @q.result 自動處理-> 處理sorting filter排序
    #    C. 如果完全沒有排序 -> 給一個預設值 (例如建立時間倒序)
    elsif @q.sorts.empty?
      @tasks = @tasks.order(created_at: :desc)
    end

    # 3. 分頁 (Pagination) - 使用 Pagy
    # @pagy 存放分頁資訊, @tasks 存放該頁的資料
    # 最後將篩選並排序好的資料丟給 Pagy, 並在此直接設定每頁幾筆 (limit) 和溢位處理 (overflow)
    @pagy, @tasks = pagy(@tasks, limit: 10, overflow: :last_page)
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
