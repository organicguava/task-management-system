class ErrorsController < ActionController::Base
  layout "errors"

  def show
    @status_code = params[:code]&.to_i || 500
    render @status_code.to_s, status: @status_code
  end
end
