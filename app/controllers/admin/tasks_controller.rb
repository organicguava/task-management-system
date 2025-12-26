class Admin::TasksController < Admin::BaseController
    before_action :set_user

    def index
        @q = @user.tasks.ransack(params.fetch(:q, {}).reverse_merge(s: "created_at desc"))
        # 取得初步結果，distinct: true 可以避免關聯查詢時出現重複資料
        @pagy, @tasks = pagy(@q.result(distinct: true), limit: 10, overflow: :last_page)
    end

    private

    def set_user
        @user = User.find(params[:user_id])
    end
end