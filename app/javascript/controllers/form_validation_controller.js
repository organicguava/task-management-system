import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "submit"]

  connect() {
    // 一進頁面先檢查一次 (確保按鈕狀態正確)
    this.validate()
  }

  validate() {
    // 檢查所有標記為 input 的欄位，是否都有值
    // 使用 .trim() 去除空白，避免有值欄位為空白
    const allFilled = this.inputTargets.every(input => input.value.trim() !== "")

    if (allFilled) {
      // 啟用按鈕
      this.submitTarget.disabled = false
      this.submitTarget.classList.remove("opacity-50", "cursor-not-allowed")
      this.submitTarget.classList.add("hover:bg-indigo-700", "cursor-pointer")
    } else {
      // 禁用按鈕
      this.submitTarget.disabled = true
      this.submitTarget.classList.add("opacity-50", "cursor-not-allowed")
      this.submitTarget.classList.remove("hover:bg-indigo-700", "cursor-pointer")
    }
  }
}