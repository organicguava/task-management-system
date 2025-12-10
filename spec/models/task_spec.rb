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

  describe "搜尋功能" do
    let!(:task1) { create(:task, title: "Ruby", status: :pending) }
    let!(:task2) { create(:task, title: "Rails", status: :completed) }

    it "可以依標題模糊搜尋" do
      expect(Task.search_by_title("Ru")).to include(task1)
      expect(Task.search_by_title("Ru")).not_to include(task2)
    end

    it "可以依狀態搜尋" do
      expect(Task.search_by_status("pending")).to include(task1)
      expect(Task.search_by_status("pending")).not_to include(task2)
    end
  end
end
