class Admin::BaseController < ApplicationController
  before_action :require_admin!
  
  private
  
  def require_admin!
    # 步驟 22 會實作角色功能
  end
end