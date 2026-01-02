require 'rails_helper'

RSpec.describe Task, type: :model do
  describe '關聯' do
    context '當建立有使用者的任務' do
      let(:task) { create(:task) }

      it '會綁定使用者' do
        expect(task.user).to be_present
      end
    end

    context '當缺少使用者時' do
      let(:task) { Task.new(title: '無主孤魂', user: nil) }

      before { task.validate }

      it '無法建立' do
        expect(task).not_to be_valid
      end

      it '回報 user 必須存在' do
        expect(task.errors[:user]).not_to be_empty
      end
    end

    context '標籤關聯' do
      it { is_expected.to have_many(:task_tags).dependent(:destroy) }
      it { is_expected.to have_many(:tags).through(:task_tags) }
    end
  end

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

  describe '標籤功能' do
    let(:task) { create(:task) }
    let(:tag1) { create(:tag, name: '工作') }
    let(:tag2) { create(:tag, name: '緊急') }

    it '可以加入多個標籤' do
      task.tags << tag1
      task.tags << tag2
      expect(task.tags.count).to eq(2)
      expect(task.tags).to include(tag1, tag2)
    end

    it '可以透過 tag_ids 批次設定標籤' do
      task.tag_ids = [ tag1.id, tag2.id ]
      expect(task.tags).to include(tag1, tag2)
    end

    it '刪除任務時會刪除關聯但不刪除標籤' do
      task.tags << tag1
      expect { task.destroy }.to change(TaskTag, :count).by(-1)
      expect(Tag.exists?(tag1.id)).to be true
    end
  end
end
