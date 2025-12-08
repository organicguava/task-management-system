class TasksController < ApplicationController
def index
    # 這裡實作排序邏輯，並加入安全過濾 (Whitelist)
    # 如果 params[:sort_by] 不在白名單內，就預設用 created_at
    sort_by = %w[created_at end_time].include?(params[:sort_by]) ? params[:sort_by] : "created_at"

    # 如果 params[:direction] 不在白名單內，就預設用 desc
    direction = %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"

    # 執行查詢:不管怎樣都用 DESC (最新的在前)，並且強制 NULLS LAST (空的在最後)
    @tasks = Task.order("#{sort_by} DESC NULLS LAST")
  # 初版長這樣：@tasks = Task.order(created_at: :desc) @ 之後可以被 View 檔案使用,且列表資料按建立時間，降冪排列
end

def new
  @task = Task.new
end

def create # 用來接收post(送)請求的
  @task = Task.new(task_params)

  if @task.save
    flash[:notice] = t("flash.tasks.create.notice")
    redirect_to tasks_path # 成功後轉跳回列表頁
  else
    # 驗證失敗時，重新渲染 new 頁面（停留在表單）
    flash.now[:alert] = t("flash.tasks.create.alert")
    render :new, status: :unprocessable_entity
  end
end

def edit
  @task = Task.find(params[:id])
end

def update
  # 1. 先找到舊資料 (跟 edit action 一樣)
  @task = Task.find(params[:id])

  # 2. 嘗試更新 (使用 Strong Parameters)
  if @task.update(task_params)
    # 成功：設定 Flash 訊息並轉跳回列表
    flash[:notice] = t("flash.tasks.update.notice")
    redirect_to tasks_path
  else
    # 驗證失敗時停留在 edit 頁面並顯示錯誤訊息
    flash.now[:alert] = t("flash.tasks.update.alert")
    render :edit, status: :unprocessable_entity
  end
end

def destroy
  @task = Task.find(params[:id]) # 如果找不到 id，Rails 會自動跳 404，這行以下都不會執行
  @task.destroy
  flash[:notice] = t("flash.tasks.destroy.notice")
  redirect_to tasks_path, status: :see_other # 必須回傳 HTTP 303 (See Other) 狀態碼，否則 Turbo 有時候會報錯。
end

private # 為了安全性，必須使用 Strong Parameters

def task_params
  params.require(:task).permit(:title, :content, :end_time)
end
end
