class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # 設定Basic Auth認證
  before_action :authenticate_in_production

  # 引入 Pagy 後端功能
  include Pagy::Backend

  # 讓 View 也可以使用這些 controller 的 helper 方法(讓 View 也可以像呼叫 link_to 或 form_with 這些 Helper 一樣呼叫)
  helper_method :current_user, :user_signed_in?

  before_action :authenticate_user! # 預設所有頁面都要驗證使用者身份，在 SessionsController 和 UsersController 裡面會跳過這個驗證

  private

  # 核心方法：從 Session 中找回目前的使用者
  # Memoization (@current_user ||= ...) 確保一個 Request 只查一次資料庫
  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  # 判斷是否已登入
  def user_signed_in?
    current_user.present?
  end

  # 擋門神：放在 Controller 的 before_action 用
  def authenticate_user!
    unless user_signed_in?
      redirect_to login_path, alert: I18n.t("flash.auth.require_login")
    end
  end

  # production 環境下啟用 Basic Auth
  def authenticate_in_production
    if Rails.env.production?
      authenticate_or_request_with_http_basic do |username, password|
        # 建議使用環境變數
        username == ENV.fetch("ADMIN_USERNAME", "admin") &&
        password == ENV.fetch("ADMIN_PASSWORD", "123456")
      end
    end
  end
end
