class TasksController < ApplicationController
def index
    @tasks = Task.all # @ 之後可以被 View 檔案使用
end

def new
  @task = Task.new
end

def create # 用來接收post(送)請求的
  @task = Task.new(task_params)

  if @task.save
    flash[:notice] = "任務已成功建立"
    redirect_to tasks_path # 成功後轉跳回列表頁
  else
    render :new # 失敗時，留在 new 頁面 (會顯示錯誤訊息)
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
    flash[:notice] = "任務更新成功"
    redirect_to tasks_path
  else
    # 失敗：回到編輯頁面 (render :edit)
    # 此時 @task 包含著使用者剛剛輸入的資料 + 錯誤訊息
    flash.now[:alert] = "更新失敗"
    render :edit
  end
end

def destroy
  @task = Task.find(params[:id]) # 如果找不到 id，Rails 會自動跳 404，這行以下都不會執行
  @task.destroy 
  flash[:notice] = "資料已刪除"
  redirect_to tasks_path, status: :see_other # 必須回傳 HTTP 303 (See Other) 狀態碼，否則 Turbo 有時候會報錯。
  
end

private # 為了安全性，必須使用 Strong Parameters

def task_params
  params.require(:task).permit(:title, :content)
end

end