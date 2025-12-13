module TasksHelper
    # index page 排序的 filter link helper
    def sort_link(column, title = nil, options = {})
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

  # 封裝 Tailwind 下拉選單樣式(form 中status , priority 都有用到)
  def tailwind_select(form, attribute, options)
    content_tag(:div, class: "relative") do
      concat form.select(attribute, options, { include_blank: false },
        class: "block appearance-none w-full bg-white border border-gray-400 hover:border-gray-500 px-4 py-2 pr-8 rounded shadow leading-tight focus:outline-none focus:shadow-outline"
      )

      # SVG Icon
      concat content_tag(:div, class: "pointer-events-none absolute inset-y-0 right-0 flex items-center px-2") {
        tag.svg(width: "18", height: "18", viewBox: "0 0 18 18", fill: "none", xmlns: "http://www.w3.org/2000/svg") do
          tag.path(d: "M14.25 6.75L9 12L3.75 6.75", stroke: "#6B7280", "stroke-width": "2", "stroke-linecap": "round", "stroke-linejoin": "round")
        end
      }
    end
  end
end
