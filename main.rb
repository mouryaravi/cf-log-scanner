require './lib/downloader'

d = Downloader.new('ravi', 'xxxxxx', 'xxxx')
p "Count: #{d.get_attachments_count(1)}"
d.save_attachments_to('~/email-attachments')

