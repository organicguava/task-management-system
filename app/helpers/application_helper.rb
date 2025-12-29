module ApplicationHelper
  # 引入 Pagy 前端 Helper (用來產生上一頁、下一頁的 HTML)
  include Pagy::Frontend

  # 內嵌 SVG 圖示的 helper
  # 用法: inline_svg_icon("icons/eye.svg", class: "h-5 w-5")
  # 這樣 SVG 可以繼承父元素的顏色 (currentColor)
  def inline_svg_icon(filename, options = {})
    file_path = Rails.root.join("app", "assets", "images", filename)
    return "" unless File.exist?(file_path)

    svg_content = File.read(file_path)

    # 如果有傳入 class，替換或加入 class 屬性
    if options[:class].present?
      if svg_content.include?('class="')
        svg_content = svg_content.gsub(/class="[^"]*"/, "class=\"#{options[:class]}\"")
      else
        svg_content = svg_content.gsub("<svg ", "<svg class=\"#{options[:class]}\" ")
      end
    end

    svg_content.html_safe
  end
end
