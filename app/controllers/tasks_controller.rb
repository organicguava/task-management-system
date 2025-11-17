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

private # 為了安全性，必須使用 Strong Parameters

def task_params
  params.require(:task).permit(:title, :content)
end

end