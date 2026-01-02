module TasksHelper
    # index page 排序的 filter link helper
    def my_sort_link(column, title = nil, options = {})
        title ||= column.titleize # 如果沒有提供 title，就把欄位名稱美化後當作標題

        # hover到選單項目的預設樣式
        default_class = "cursor-pointer block px-4 py-2 text-sm w-full text-left"

        # 如果目前正在依這個欄位排序，用特別的設計題使用者
        if column == params[:sort_by]
            options[:class] = "#{default_class} font-bold text-blue-600 bg-gray-50 #{options[:class]}".strip
        else
            options[:class] = "#{default_class} text-gray-700 hover:bg-gray-100 hover:text-gray-900 #{options[:class]}".strip
        end

        # 產生排序連結，點擊後會帶上 sort_by 參數
        link_to title, { sort_by: column }, options
    end

    # 狀態標籤的樣式對應
    STATUS_COLORS = {
      "pending" => "bg-gray-100 text-gray-600",
      "processing" => "bg-blue-100 text-blue-600",
      "completed" => "bg-green-100 text-green-600"
    }.freeze

    # 優先級標籤的樣式對應
    PRIORITY_COLORS = {
      "low" => "bg-gray-100 text-gray-600",
      "medium" => "bg-yellow-100 text-yellow-600",
      "high" => "bg-red-100 text-red-600"
    }.freeze

    # 產生狀態標籤 (Badge)
    def status_badge(status)
      status_class = STATUS_COLORS[status] || "bg-gray-100 text-gray-600"
      content_tag :span, t("activerecord.enums.task.status.#{status}"),
                  class: "px-3 py-1 inline-flex text-xs leading-5 font-semibold rounded-full #{status_class}"
    end

    # 產生優先級標籤 (Badge)
    def priority_badge(priority)
      priority_class = PRIORITY_COLORS[priority] || "bg-gray-100 text-gray-600"
      content_tag :span, t("activerecord.enums.task.priority.#{priority}"),
                  class: "px-3 py-1 inline-flex text-xs leading-5 font-semibold rounded-full #{priority_class}"
    end

    # 產生單一標籤 Badge（標籤名稱是動態資料，直接顯示）
    def tag_badge(tag)
      content_tag :span, tag.name,
                  class: "px-3 py-1 inline-flex text-xs leading-5 font-semibold rounded-full"
    end
end
