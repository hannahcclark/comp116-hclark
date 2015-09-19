# Packet Sleuth

## Set 1
1. There are 861 packets in the set.

2. The protocol used was FTP.

3. FTP does not use encryption, so the data being sent can easily be reconstructed into the exact files, which may contain sensitive information, and any authentication is in plain text.

4. FTPS uses encryption, so is more secure.

5. 192.168.1.8

6. USER: defcon PASSWORD: m1ngisablowhard

7. 6 files were transferred.

8. COaqQWnU8AAwX3K.jpg

   CDkv69qUsAAq8zN.jpg

   CNsAEaYUYAARuaj.jpg 

   CLu-m0MWoAAgjkr.jpg

   CKBXgmOWcAAtc4u.jpg

   CJoWmoOUkAAAYpx.jpg

9. See other files in directory for extracted contents

## Set 2

10. There are 77982 packets in this set.

11. 1 plaintext account was found in this set

12. I used ettercap -T -r set2.pcap to output all packets, and piped that to grep several times using different account related keywords: user, pass, pswd, pwd, login, USER, PASS, PSWD, PWD, LOGIN.

13. Username: larry@radsot.com, Password: Z3lenzmej, Protocol: IMAP, IP address: 87.120.13.118, Domain: neterra.net, Port: 143

14. 1 of 1 pair is legitmate.

## Set 3

## General Questions
19. To verify the legitmacy, I used wireshark to look at the TCP streams that included a login attempt, and checked that the combination was accepted, which appeared as SUCCESS, 200, logged in, etc. after the login attempt

20. When sending authentication information over the network, use a secure protocol, such as HTTPS, so that anything sent over the network is encrypted and more difficult to read.
