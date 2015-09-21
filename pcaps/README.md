# Packet Sleuth

## Set 1
1) There are 861 packets in the set.

2) The protocol used was FTP.

3) FTP does not use encryption, so the data being sent can easily be reconstructed into the exact files, which may contain sensitive information, and any authentication is in plain text.

4) FTPS uses encryption, so is more secure.

5) 192.168.1.8

6) defcon:m1ngisablowhard

7) 6 files were transferred.

8) 

* COaqQWnU8AAwX3K.jpg
* CDkv69qUsAAq8zN.jpg
* CNsAEaYUYAARuaj.jpg 
* CLu-m0MWoAAgjkr.jpg
* CKBXgmOWcAAtc4u.jpg
* CJoWmoOUkAAAYpx.jpg

9) See other files in directory for extracted contents

## Set 2

10) There are 77982 packets in this set.

11 and 13) 1 username-password pair was found:

* larry@radsot.com:Z3lenzmej, Protocol: IMAP, IP address: 87.120.13.118, Domain: 76.0d.78.57.d6.net, Port: 143


12) I used ettercap -T -r set2.pcap to output all packets, and piped that to grep several times using different login or account related keywords: user, pass, pswd, pwd, login, USER, PASS, PSWD, PWD, LOGIN.

14) 1/1 pair (larry@radsot.com:z3lenzmej) is legitmate.

## Set 3
15 and 16) 3 username-password pairs were found:

* nab01620@nifty.com:Nifty->takirin1, Protocol: IMAP, IP address: 210.131.4.155, Domain: N/A IP did not resolve to a domain, Port: 143
* seymore:butts, Protocol: HTTP, IP address: 162.22.171.208, Domain: forum.defcon.org, Port: 80
* jeff:asdasdasd, Protocol: HTTP, IP address: 54.191.109.23, Domain:ec2-54-191-109-23.us-west-2.compute.amazonaws.com, Port: 80


17) 1/3 pairs (nab01620@nifty.com:Nifty->takirin1) is legitmate. jeff:asdasdasd is most likely illegitimate based on info from the packets containing that login being found in conversations that involve unauthorized in the response. That is either due to a browser not supplying credentials correctly or the password being incorrect, so it cannot be definitively marked as illegitimate, although it most likely is. The legitimacy of the seymore:butts login could not be determined. The response in TCP streams with that login was that the resource was forbidden to access over HTTP, so it is unclear as to whether the login would be valid if the user were using https to access the resource.

18) The list of IP address-host mappings can be found in the file set3-ip-host.txt. The list does not contain IP addresses that do not map to a domain name. A list of all IP addresses including those without domain mappings can be found in the file set3-all-ips.txt. These lists wer found using Wireshark's address resolution tool.

## General Questions
19) To verify the legitmacy, I used wireshark to look at the TCP streams that included a login attempt, and checked that the combination was accepted, which appeared as SUCCESS, 200, logged in, etc. after the login attempt, or looked for indications that it was denied, such as unauthorized.

20) When sending authentication information over the network, use a secure protocol, such as HTTPS, so that anything sent over the network is encrypted and more difficult to read.

## Additional information
This assignment took be roughly 7 hours.

I discussed possible tools that could be used with Arthur Berman, to the extent of the use of tools that were demonstrated in class.

The tools I used were Wireshark, Ettercap, grep, whois, and nslookup.
