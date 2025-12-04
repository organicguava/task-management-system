require 'rails_helper'

RSpec.describe Task, type: :model do
  describe '驗證' do
    context 'title 欄位' do
      it { is_expected.to validate_presence_of(:title) }
    end
  end

  describe '資料庫' do
    it { is_expected.to have_db_column(:title).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:content).of_type(:text) }
  end
end
