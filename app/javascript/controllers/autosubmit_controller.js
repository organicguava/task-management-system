import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="autosubmit"
export default class extends Controller {
  static targets = ["form"]

  search() {
    // 使用 Rails Turbo 的 requestSubmit，這樣不會換頁，而是局部更新
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.element.requestSubmit()
    }, 200) // 稍微延遲一點點，避免連點造成負擔
  }
}
