class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # 設定Basic Auth認證
  before_action :authenticate_in_production

  private

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
