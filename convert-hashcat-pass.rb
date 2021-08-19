#!/usr/bin/env ruby

## This script takes in the output
## of hashcat dictionary.txt --show
## and prints the actual text to the file

f = File.open('cracked.txt')

f.each_line do |line|
  cred = line.strip()
  nohash = cred[33..-1]
  if nohash[0..3] == "$HEX"
    hex = nohash.split("[")[1].split("]")[0]
    puts([hex].pack("H*"))
  else
    puts(nohash)
  end
end
