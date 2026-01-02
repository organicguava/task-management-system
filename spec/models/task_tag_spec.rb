require 'rails_helper'

RSpec.describe TaskTag, type: :model do
  describe '關聯' do
    it { is_expected.to belong_to(:task) }
    it { is_expected.to belong_to(:tag) }
  end

  describe '驗證' do
    # 需要先建立一個 task_tag 才能測試 uniqueness（shoulda-matchers 的要求）
    subject { create(:task_tag) }

    # with_message 要符合 TaskTag model 中自訂的錯誤訊息
    it { is_expected.to validate_uniqueness_of(:tag_id)
    .scoped_to(:task_id)
    .with_message(:already_added) }
  end

  describe '唯一性約束' do
    let(:task) { create(:task) }
    let(:tag) { create(:tag) }
    let!(:existing_task_tag) { TaskTag.create!(task: task, tag: tag) }

    it '不允許同一任務重複加入相同標籤' do
      duplicate = TaskTag.new(task: task, tag: tag)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:tag_id]).to be_present
    end
  end
end
