#!/usr/bin/env ruby

# This checks a password list against the Have I Been Pwned redis server
require 'digest'
require 'redis'

redis = Redis.new

f = File.open('pass.txt')
f.each_line do |line|
  pass = line.strip()
  sha1 = Digest::SHA1.hexdigest pass
  sha1.upcase!
  puts "[*] Checking: #{sha1}"
  result = redis.get(sha1)
  if result
    puts "\t[-] Found #{sha1} - #{result.rjust(15, "0")} times..."
  end
end
