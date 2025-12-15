
require "pagy/extras/i18n"
require "pagy/extras/overflow"

# 設定預設值 (v9 允許這樣設定，且建議設定 overflow)
Pagy::DEFAULT[:items] = 10
Pagy::DEFAULT[:overflow] = :last_page
