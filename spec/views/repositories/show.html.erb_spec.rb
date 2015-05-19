require 'spec_helper'

describe "repositories/show.html.erb" do
  
  before(:each) do
    @repo = FactoryGirl.create(:repository)
    @repo.to_disk
    assign(:repository, @repo)
    assign(:general_settings, Setting.get(:general_settings))
    assign(:current_path, '')
  end
  
  describe "with commit" do
    before(:each) do  
      tree = RJGit::Tree.new_from_hashmap(@repo.repository, { "README.md" => "# This is a test repo with one directory and two files.", "scriptdir" => { "reverse.rb" => "ruby -e 'File.open('foo').each_line { |l| puts l.chop.reverse }'" }} )
      @commit = RJGit::Commit.new_with_tree(@repo.repository, tree, "Test commit message", RJGit::Actor.new("test","test@repotag.org"))
      @repo.repository.update_ref(@commit)
    
      assign(:commit, @commit)
      dir_list, file_list = get_listing(@repo.repository, "refs/heads/master", nil)
      assign(:file_list, file_list)
      assign(:directory_list, dir_list)
    
      render
    end
  
    it "should display the repository name" do
      expect(rendered).to have_text @repo.owner.username
      expect(rendered).to have_text @repo.name
    end
  
    it "should display a breadcrumb trail" do
      expect(rendered).to have_selector(:xpath, "//ul[@class='breadcrumb']")
    end
  
    it "should display committed directories" do
      expect(rendered).to have_selector(:xpath, "//tr[@data-path='scriptdir']")
      expect(rendered).to have_text "scriptdir"
    end
  
    it "should display committed files" do
      expect(rendered).to have_selector(:xpath, "//td[@class='blob']")
      expect(rendered).to have_text "README.md"
    end
    
    it "should display the rendered README if it exists" do
      skip "Not implemented yet."
    end

  end
  
  describe "without commit" do
    
    before(:each) { render }
    
    it "should report that the repository is empty" do
      expect(rendered).to have_text "Empty repository."
    end
    
    it "should not display the table" do
      expect(rendered).not_to have_selector(:xpath, "//table[@id='viewer']")
    end
  end
  
  after(:each) do
    remove_temp_repo(@repo.repository.path)
  end
  
end
