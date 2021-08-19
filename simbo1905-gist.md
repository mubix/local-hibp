# How To Load The HIBP Pwned Passwords Database Into Redis

[NIST](https://pages.nist.gov/800-63-3/sp800-63b.html) recommends that when users are trying to set a password you should reject those that are commonly used or compromised:

    When processing requests to establish and change memorized secrets, 
    verifiers SHALL compare the prospective secrets against a list that 
    contains values known to be commonly-used, expected, or compromised.

But how do you know what are the compromised passwords? Luckily [Troy Hunter](https://www.troyhunt.com/ive-just-launched-pwned-passwords-version-2/) put a lot of effort into building the "Have I Been Pwned (HIBP)" database with the SHA1 hashes of 501,636,842 passwords that have been compromised on the internet. Sweet. 

This means that to prevent a user setting a compromised password like `P@ssword` you can look it up on a public HIBP service such as [this one](https://haveibeenpwned.com/Passwords) and reject it. 

If you are running a security sensitive service it is probably a bad idea to make a call to a public password hash lookup service. To get around that the public Pwned Password API at https://haveibeenpwned.com/API/v2#PwnedPasswords has you send the first 5 chars of the hash and they respond with all the matches. That might be slow or return a lot of data or be offline. So you might want to load the HIBP database into a private store such as redis and check the SHA1 hash against that authorative store. You can then use a private secure API to your own redis and just do an exact match SHA1 check which will be fast and since it is on your infrastructure you can ensure that it is made highly available. 

Note Redis expects everything to be in RAM so you will need a server with 64G RAM. The AWS price caculator suggests thats
$325 a month so you might consider a database that is disk backed which would be slower but cheaper (e.g. mongodb see another gist here on github for that). You could also consider a combiation of a fast check to redis of the most commonly occuring passwords then a slow check to full dataset held in a cheaper-to-host-at-scale database. The file is organised by "most occurences decending" so you could load the first XGi which would be the most commonly occuring passwords used or traded on the internet that you can put in redis for a fast check then hit a cheaper-to-host-at-scale database.

## Prerequisites

These instructions assume that you drive a mac but should be as straightforward on linux. 

 * Over 50Gi of disk (uncompressed the database is 33Gi then add to that the compressed 8Gi )
 * Homebrew to install command line tools
     * `brew install aria2` for the `aria2c` bit torrent download client
     * `brew install p7zip` for the `7za` tool to uncompress a the `.txt.7z` file
     * `brew install wget` because everyone should have this
 * XTools to compile redis-cli
     1. wget http://download.redis.io/redis-stable.tar.gz
     1. tar zxf redis-stable.tar.gz
     1. cd redis-stable
     1. make 
     1. sudo cp src/redis-cli /usr/local/bin
 * A redis server
 
## Steps

Note that it took an hour to download the 8Gi torrent on my broadband. 

The redis-cli command assumes that your redis server is local else you have port forwarded the default port of 6379 to your server. If not you can pass commandline args to [redis-cli](https://www.mankier.com/1/redis-cli)

 1. `aria2c https://downloads.pwnedpasswords.com/passwords/pwned-passwords-2.0.txt.7z.torrent`
 1. `7za x pwned-passwords-2.0.txt.7z`
 1. `awk 'BEGIN {FS = ":"}{print "*3\r\n$3\r\nSET\r\n$40\r\n" $1 "\r\n$" length($2+0) "\r\n" $2 "\r"}' pwned-passwords-2.0.txt | redis-cli --pipe`
 
## References

 * [Redis Mass Insertion](https://redis.io/topics/mass-insert)
 * [I've Just Launched "Pwned Passwords" V2](https://www.troyhunt.com/ive-just-launched-pwned-passwords-version-2/)
 * [Pwned Passwords](https://haveibeenpwned.com/Passwords)
 
 
