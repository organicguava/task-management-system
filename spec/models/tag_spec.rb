require 'rails_helper'

RSpec.describe Tag, type: :model do
  describe '驗證' do
    # shoulda-matchers 的 validate_uniqueness_of 需要先有一筆資料在資料庫中
    # 因為 name 有 NOT NULL 約束，必須提供有效的 subject
    subject { build(:tag) }

    context 'name 欄位' do
      it { is_expected.to validate_presence_of(:name) }
      it { is_expected.to validate_uniqueness_of(:name) }
    end
  end

  describe '關聯' do
    it { is_expected.to have_many(:task_tags).dependent(:destroy) }
    it { is_expected.to have_many(:tasks).through(:task_tags) }
  end

  describe '資料庫' do
    it { is_expected.to have_db_column(:name).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_index(:name).unique }
  end

  describe '多對多關聯行為' do
    let(:tag) { create(:tag) }
    let(:task) { create(:task) }

    it '可以關聯到任務' do
      tag.tasks << task
      expect(tag.tasks).to include(task)
    end

    it '刪除標籤時，會刪除關聯但不刪除任務' do
      tag.tasks << task
      expect { tag.destroy }.to change(TaskTag, :count).by(-1)
      expect(Task.exists?(task.id)).to be true
    end
  end
end
