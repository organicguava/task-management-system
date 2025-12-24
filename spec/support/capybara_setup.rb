# --- 註冊 CI 專用的 Headless Chrome Driver ---
# 放在 RSpec.configure 區塊外面是正確的
Capybara.register_driver :selenium_chrome_headless_in_ci do |app|
  options = Selenium::WebDriver::Chrome::Options.new

  # CI 環境必備參數，防止崩潰
  options.add_argument("--headless")
  options.add_argument("--no-sandbox")
  options.add_argument("--disable-dev-shm-usage")
  options.add_argument("--disable-gpu")
  options.add_argument("--window-size=1400,1400")

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end
