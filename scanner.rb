require 'gmail'
require 'zlib'

USERNAME = "xxx@a.com"
PASSWORD = "asadfasf"
MAILBOX_FOLDER = 'applogs'
LAST_N_DAYS = 1
LOCAL_FOLDER = '~/email-attachments'
UNZIPEED_EXT = 'unzipped'


def download_attachment(email)
  #p "Saving attachment for: #{email.message.inspect}"
  Dir.chdir(LOCAL_FOLDER)
  email.message.attachments.each do |f|
    #p "Saving attachment: #{f.inspect}"
    File.write(File.join(Dir.pwd, f.filename), f.body.decoded)
  end
end

def download_all_attachments(emails)
  emails_with_attachments = emails.select { |email| !email.message.attachments.empty? }
  emails_with_attachments.each { |email| download_attachment(email) }
end

def gunzip_attachment(folder, file)
  #p "Gunzipping attachment file: #{file}"
  Zlib::GzipReader.open([folder, file].join("/")) do |gz|
    #p "writing file into: #{gz.orig_name}"
    File.open([folder, UNZIPEED_EXT, gz.orig_name].join("/"), 'w') do |f|
      f.write gz.read
    end
  end
  rescue Zlib::GzipFile::Error
    p "Error while opening gz file: #{file}"
end

def gunzip_all_attachments(folder)
  Dir.foreach(folder) do |file|  
    if !File.directory?([folder, file].join("/"))
      gunzip_attachment(folder, file)
    end
  end
end

def download_gmail_attachments 
  Gmail.connect(USERNAME, PASSWORD) do |gmail|
    app_logs = gmail.mailbox(MAILBOX_FOLDER)
    puts "Total attachments in mailbox: #{MAILBOX_FOLDER} : #{app_logs.count}"
    required_app_logs = app_logs.emails(after: Date.today.prev_day(LAST_N_DAYS))
    p "Downloading #{required_app_logs.count} attachments"

    download_all_attachments(required_app_logs)

    gmail.logout
  end
end

def search_errors(folder)
  list = []
  Dir.foreach(folder) do |file|
    unless File.directory?(file)
      File.open([folder, file].join('/'), 'r') do |f|
        list << f.lines.select { |line| line.include?("ERROR") }
      end
    end
  end
  list.flatten
end

#download_gmail_attachments
gunzip_all_attachments(LOCAL_FOLDER)
error_list = search_errors([LOCAL_FOLDER, UNZIPEED_EXT].join("/"))

p "total error count: #{error_list.size}"
unique_errors = {}
error_list.each do |error|
  (str1, str2, str3) = error.partition("ERROR")
  unique_errors[str3] = ''
end

p "total  unique error count: #{unique_errors.size}"

unique_errors.keys.each do |error|
  p "================================================================="
  p error
end

