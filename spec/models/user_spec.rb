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

  describe "角色功能" do
    describe "#admin?" do
      context "當使用者是管理員" do
        subject { build(:user, :admin) }

        it { is_expected.to be_admin }
      end

      context "當使用者不是管理員" do
        subject { build(:user, admin: false) }

        it { is_expected.not_to be_admin }
      end
    end

    describe "before_destroy callback (最後一位管理員保護)" do
      context "當只剩下一位管理員" do
        let!(:last_admin) { create(:user, :admin) }

        it "無法刪除最後一位管理員" do
          expect { last_admin.destroy }.not_to change(User, :count)
        end

        it "回傳 false" do
          expect(last_admin.destroy).to be false
        end

        it "新增錯誤訊息" do
          last_admin.destroy
          expect(last_admin.errors[:base]).to include(I18n.t("activerecord.errors.models.user.attributes.base.last_admin"))
        end
      end

      context "當有多位管理員" do
        let!(:admin1) { create(:user, :admin) }
        let!(:admin2) { create(:user, :admin) }

        it "可以刪除其中一位管理員" do
          expect { admin1.destroy }.to change(User, :count).by(-1)
        end
      end

      context "當刪除一般使用者" do
        let!(:admin) { create(:user, :admin) }
        let!(:normal_user) { create(:user, admin: false) }

        it "可以正常刪除" do
          expect { normal_user.destroy }.to change(User, :count).by(-1)
        end
      end
    end
  end
end
