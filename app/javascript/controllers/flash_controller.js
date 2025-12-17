import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="flash"
export default class extends Controller {
  connect() {
    // 自動消失倒數
    this.timeout = setTimeout(() => {
      this.dismiss()
    }, 4000) // 延長一點時間到 4秒，讓使用者看得更清楚
  }

  dismiss() {
    // 1. 加入淡出效果與位移
    this.element.classList.add("opacity-0", "translate-x-full")
    
    // 2. 等待動畫結束後移除元素
    setTimeout(() => {
      this.element.remove()
    }, 500) // 這裡的時間要配合 duration-500
  }

  disconnect() {
    clearTimeout(this.timeout)
  }
}