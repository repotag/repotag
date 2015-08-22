require "spec_helper"

describe HookMailer do
  before(:each) do
    @user = FactoryGirl.create(:user)
    @repository = FactoryGirl.create(:repository)
    @repository.repository.create!
  end
  
  it "sends an activity report" do
    mail_count = ActionMailer::Base.deliveries.count+1
    HookMailer.activity_report(@user, @repository).deliver_now
    expect(ActionMailer::Base.deliveries).to have(mail_count).email
  end
  
  it "sends mail with commit details if so configured" do
    @testfile = 'test_file.txt'
    File.open(File.join(File.dirname(@repository.repository.path), @testfile), 'w') {|file| file.write("This is a new file to add.") }
    RJGit::Porcelain.add(@repository.repository, @testfile)
    RJGit::Porcelain.commit(@repository.repository, "Initial commit")
    @commit = @repository.repository.head
    mail_count = ActionMailer::Base.deliveries.count+1
    HookMailer.commit_details(@user, @repository, @commit).deliver_now
    expect(ActionMailer::Base.deliveries).to have(mail_count).email
    expect(ActionMailer::Base.deliveries.first.body.decoded).to include(@commit.id)
  end
  
  after(:each) do
    path = File.dirname(@repository.repository.path)
    FileUtils.rm_rf(path) if File.exists?(path)
  end
end
