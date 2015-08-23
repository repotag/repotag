require "spec_helper"

describe HookMailer do
  before(:each) do
    @user = FactoryGirl.create(:user)
    @repository = FactoryGirl.create(:repository)
    @repository.to_disk
  end
  
  it "sends an activity report" do
    mail_count = ActionMailer::Base.deliveries.count+1
    HookMailer.activity_report(@user, @repository).deliver_now
    expect(ActionMailer::Base.deliveries).to have(mail_count).email
  end
  
  it "sends mail with commit details if so configured" do
    @repository.populate_with_test_data
    @commit = @repository.repository.head
    mail_count = ActionMailer::Base.deliveries.count+1
    HookMailer.commit_details(@user, @repository, @commit).deliver_now
    expect(ActionMailer::Base.deliveries).to have(mail_count).email
    expect(ActionMailer::Base.deliveries.first.body.decoded).to include(@commit.id)
  end
  
  after(:each) do
    path = File.dirname(@repository.filesystem_path)
    FileUtils.rm_rf(path) if File.exists?(path)
  end
end
