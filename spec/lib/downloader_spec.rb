require 'spec_helper'
require 'downloader'

describe Downloader do
  before { @downloader = Downloader.new('ravi@a.com', 'pass', 'folder')  }
  subject { @downloader }

  it { should respond_to(:username) }
  it { should respond_to(:password) }
  it { should respond_to(:folder) }
  it { should be_valid }

  describe "should be invalid with empty username" do
    before { @downloader.username = ' ' }
    it { should_not be_valid }
  end

  describe "should be invalid with empty password" do
    before { @downloader.password = ' ' }
    it { should_not be_valid }
  end

  describe "should be invalid with empty folder" do
    before { @downloader.folder = ' ' }
    it { should_not be_valid }
  end

  describe "get attachments count" do
    it "should description" do
      
    end
    
  end



end