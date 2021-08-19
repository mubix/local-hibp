#!/usr/bin/env ruby

require 'digest'
require 'redis'

redis = Redis.new

f = File.open('cracked_with_users.txt')

f.each_line do |line|
  credline = line.strip()
  if credline.include? ":"
    # Split the line into its respective parts
    credarray = credline.split(":")
    user = credarray[0]
    hash = credarray[1].upcase
    if credarray.length > 2
      nohash = credarray[2]
    else
      nohash = ""
    end
    pass = ""

    # Convert the HEX passwords to their text version
    if nohash[0..3] == "$HEX"
      hex = nohash.split("[")[1].split("]")[0]
      pass = [hex].pack("H*")
    else
      pass = nohash
    end

    sha1 = Digest::SHA1.hexdigest pass
    sha1.upcase!

    # After calculating the SHA1 mark blank passwords more obviously
    if hash == "31D6CFE0D16AE931B73C59D7E0C089C0"
      pass = "BLANK PASSWORD"
    end


    puts "[*] Checking: #{user} NTLM: #{hash} SHA1: #{sha1} - Password: #{pass}"
    result = redis.get(sha1)
    if result
      puts "[-] Found #{user} NTLM: #{hash} SHA1: #{sha1} - #{result.rjust(15, "0")} times..."
    end
  end
end
