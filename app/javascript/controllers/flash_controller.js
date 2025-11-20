import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="flash"
export default class extends Controller {
  connect() {
    console.log("Flash controller connected!") //除錯用，確保JS有被載入
    this.element.classList.add("transition-opacity", "duration-500", "ease-out")
    // 當元素被放入 DOM 時，會自動執行此方法
    this.timeout = setTimeout(() => {
      this.dismiss()
    }, 3000)
  }

  dismiss() {
    // 加入 Tailwind 的過渡效果 class

    this.element.classList.add("opacity-0")
    setTimeout(() => {
      this.element.remove()
    }, 500)
  }

  disconnect() {
    clearTimeout(this.timeout)
  }
}