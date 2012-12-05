require 'rubygems'
gem 'activemodel'

require 'active_model'
require 'gmail'

class Gmail::Message
  def save_attachments_to(local_folder)
    Dir.chdir(local_folder)
    self.message.attachments.each do |f|
      File.write(File.join(Dir.pwd, f.filename), f.body.decoded)
    end
  end
end

class Downloader 

  include ActiveModel::Validations
  attr_accessor :username, :password, :folder

  validates :username, presence: true
  validates :password, presence: true
  validates :folder, presence: true

  def initialize(username, password, folder)
    @username = username
    @password = password
    @folder = folder
  end

  def get_attachments_count(last_n_days=1)
    count = 0
    get_mail_folder_mails last_n_days do |mails|
      count = mails.count
    end
    count
  end

  def save_attachments_to(local_folder, last_n_days=1)
    get_mail_folder_mails last_n_days do |mails|
      download_attachments(mails, local_folder)
    end
  end

  private

  def get_mail_folder_mails(last_n_days)
    Gmail.connect(@username, @password) do |gmail|
      mail_folder_mails = gmail.mailbox(folder).mails(
        after:Date.today.prev_day(last_n_days), 
        subject:'Server Log triop from app4')
      yield(mail_folder_mails)
      p "After Yield...."
    end
  end

  def download_attachments(emails, local_folder)
    emails_with_attachments = emails.select {|email| !email.message.attachments.empty? }
    emails_with_attachments.each { |email| email.save_attachments_to(local_folder) }
  end


end