# Setup: run the following: "gem install net-sftp"

# Configuration:
# Make sure you use forward slashes instead of back slashes in all paths below
local_path = "//10.100.10.117/EpicorData/Reports/GOODDATAAU"
file_filter = "*.csv"
local_backup_path = "//10.100.10.115/attachments/gooddata/AU"
remote_host = "na1-di.gooddata.com"
remote_username = "i0red9abtzripur9332jvk320ghjyzgx@jbutler@srsmith.com"
remote_password = "SRsmithb28"
remote_path = "/projects/ED/rVkneGGKCXjxQ1acKaruYAvUf8VIF5/epicor"

require 'net/sftp'

def rename_file(file, name)
	begin
		File.rename(file, name)
	rescue Exception => e
		$stderr.puts "Failed to rename #{file} to #{name}\n"
		raise e
	end	
end

def send_file(sftp, path, file)
	path = File.join(path, File.basename(file))
	begin
		sftp.upload!(file, path)
	rescue Exception => e
		$stderr.puts "Failed to move #{file} to sftp path #{path}!\n"
		raise e
	end
end

def move_to(path, file)
	begin
		File.rename(file, File.join(path, File.basename(file)))
	rescue Exception => e
		$stderr.puts "Failed to move #{file} to #{path}.\n"
	end
end

begin
	sftp = Net::SFTP.start(remote_host, remote_username, password: remote_password)
rescue Exception => e
	$stderr.puts "Failed to connect to #{remote_host}!  Server not responding or incorrect credentials.\n"
	raise e
end
targets = File.join(local_path, file_filter)
Dir.glob(targets) do |file|
	new_name = File.join File.dirname(file), "#{File.basename(file, '.*')}_#{Time.now.strftime('%Y%m%d')}#{File.extname(file)}"
	rename_file(file, new_name)
	file = new_name
	send_file(sftp, remote_path, file)
	move_to(local_backup_path, file)
end