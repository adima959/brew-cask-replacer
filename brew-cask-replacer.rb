#!/usr/bin/env ruby
require 'fileutils'

# Array of installed applications to exclude. Ex: Firefox Beta
# exclude = ["firefox"]
exclude = ["expressvpn"]

Dir.glob('/Applications/*.app').each do |path|
  next if File.symlink?(path)

  # Remove version numbers at the end of the name
  app = path.slice(14..-1).sub(/.app\z/, '').sub(/ \d*\z/, '')
  searchresult = `brew search #{app}`.split("\n").select{ |i| i[/(?:^|\/)#{app}$/i] }

  next unless searchresult[0]

  token = searchresult[0].split("/")[-1]

  next unless exclude.grep(/#{token}/).empty?

  puts "Installing #{token}..."

  begin
    FileUtils.mv(path, File.expand_path('~/.Trash/'))
  rescue Errno::EPERM, Errno::EEXIST
    puts "ERROR: Could not move #{path} to Trash"
    next
  end
  puts `brew install --cask #{token} $(echo $HOMEBREW_CASK_OPTS)`
end
