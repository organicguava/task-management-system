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
end
