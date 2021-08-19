# Local Have-I-Been-Pwned 
How to set up a local copy of Have-I-Been-Pwned's password checking service


- Step 1: Follow the steps here: https://gist.github.com/simbo1905/1ea8eacdfccafd3e666ebcdc0637eb41 and just in case that ever disappears you can use [the local copy](simbo1905-gist.md) 
  - **Word of warning, this takes about 6-7 hours to load and takes ~70gb of space (27 for the file, 35ish for the Redis database, you can delete the file afterwards)**
- Step 2: Check your passwords list against the Redis database you now have using [this script](check-localhibp.rb)

In order to get a `pass.txt` you can use any dictionary or you can pull it out of Hashcat.

You can do it one of two ways based on what data you want. IF you wnat to know just what bad passwords exist in the domain you can do it this way:
- Step 1: `hashcat.exe -m1000 demodomain.ntds --show > cracked.txt`
- Step 2:  Then use [convert-hashcat-pass.rb](convert-hashcat-pass.rb) `ruby convert-hashcat-pass.rb > pass.txt`

Or if you want to get a sense of how many users in the domain has passwords in the HIB
- Step 1: `hashcat.exe -m1000 demodomain.ntds --show --username > cracked_with_users.txt`
