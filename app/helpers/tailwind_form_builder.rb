class TailwindFormBuilder < ActionView::Helpers::FormBuilder # 建立一個自訂的 FormBuilder，命名為 TailwindFormBuilder
  # 定義一個 tailwind_select 方法，參數和 Rails 內建的 select 方法相同
  def tailwind_select(attribute, choices, options = {}, html_options = {})
    # FormBuilder 裡面存取 view helper 要用 @template
    @template.content_tag(:div, class: "relative") do
      # 呼叫父層(原本Rails)的 select 方法 (super)
      # 這裡加上預設的 Tailwind class
      default_class = "block appearance-none w-full bg-white border border-gray-400 hover:border-gray-500 px-4 py-2 pr-8 rounded shadow leading-tight focus:outline-none focus:shadow-outline"
      html_options[:class] = "#{default_class} #{html_options[:class]}"

      # 產生 select 標籤
      @template.concat select(attribute, choices, options, html_options)

      # 加上 SVG Icon
      @template.concat @template.content_tag(:div, class: "pointer-events-none absolute inset-y-0 right-0 flex items-center px-2") {
        @template.tag.svg(width: "18", height: "18", viewBox: "0 0 18 18", fill: "none", xmlns: "http://www.w3.org/2000/svg") do
          @template.tag.path(d: "M14.25 6.75L9 12L3.75 6.75", stroke: "#6B7280", "stroke-width": "2", "stroke-linecap": "round", "stroke-linejoin": "round")
        end
      }
    end
  end
end
