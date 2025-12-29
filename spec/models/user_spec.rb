require 'rails_helper'

RSpec.describe User, type: :model do
  describe "驗證" do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email) }
    it { is_expected.to have_secure_password }
  end


  describe "關聯" do
    it { is_expected.to have_many(:tasks).dependent(:destroy) }
  end


  describe "Counter Cache (tasks_count)" do
    let(:user) { create(:user) }

    it "新使用者的 tasks_count 預設為 0" do
      expect(user.tasks_count).to eq(0)
    end

    it "新增任務時自動增加 tasks_count" do
      expect {
        create(:task, user: user)
      }.to change { user.reload.tasks_count }.from(0).to(1)
    end

    it "刪除任務時自動減少 tasks_count" do
      task = create(:task, user: user)
      expect(user.reload.tasks_count).to eq(1)

      expect {
        task.destroy
      }.to change { user.reload.tasks_count }.from(1).to(0)
    end

    it "刪除使用者時連帶刪除任務" do
      user_to_delete = create(:user)
      create(:task, user: user_to_delete)
      create(:task, user: user_to_delete)

      expect {
        user_to_delete.destroy
      }.to change(Task, :count).by(-2)
    end
  end
end
