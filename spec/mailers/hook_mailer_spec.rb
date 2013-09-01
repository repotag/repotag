require "spec_helper"

describe HookMailer do
  before(:each) do
    @user = FactoryGirl.create(:user)
    @repository = FactoryGirl.create(:repository)
    @repository.repository.create!
  end
  
  it "should send an activity report" do
    HookMailer.activity_report(@user, @repository).deliver
    ActionMailer::Base.deliveries.should have(1).email
  end
  
  it "should send mail with commit details if so configured" do
    @testfile = 'test_file.txt'
    File.open(File.join(File.dirname(@repository.repository.path), @testfile), 'w') {|file| file.write("This is a new file to add.") }
    RJGit::Porcelain.add(@repository.repository, @testfile)
    RJGit::Porcelain.commit(@repository.repository, "Initial commit")
    @commit = @repository.repository.head
    HookMailer.commit_details(@user, @repository, @commit).deliver
    ActionMailer::Base.deliveries.should have(1).email
    ActionMailer::Base.deliveries.first.body.decoded.should include(@commit.id)
  end
  
  after(:each) do
    path = File.dirname(@repository.repository.path)
    FileUtils.rm_rf(path) if File.exists?(path)
  end
end
