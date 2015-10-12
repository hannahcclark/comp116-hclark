# Incident Alarm

A Ruby program to detect various scans and other security incidents in a live stream of network packets, a pcap file, or a server log.

## Usage

ruby alarm.rb [options]

-r, --read-log logfile		Scan server log in Apache common or combined log format for incidents

-p, --pcap-file pcapfile	Scan packets from pcap file for incidents.

-h, --help			Output usage information and exit

It defaults to sniffing packets when no options are specified. If both server log and pcap files are specified, it will first scan the server log, then scan the pcap file. The incident count will begin at 0 for each file, rather than continuing increasing the same incident count for all files.

Sudo will likely be required when running using a live stream of packets.

The interface specified in the code for a live stream of packets may need to be changed as appropriate for the machine it is being run on.


## Quality of Detection

The heuristics used for the alarm are not actually very good. Because the alarm only looks at one packet at a time in isolation for the packet scanner, it will not necessarily detect scans such as SYN or connection scans. Those scans as well as the NULL, FIN, and Xmas scans are not at all detectable on the server logs because it registers requests, not packets. In addition, for the other Nmap scans detected, it depends on Nmap being in the User-Agent request header for HTTP requests. This therefore limits the number of scans detected to those using HTTP requests. It is further limited by Nmap's option to change the User-Agent.

The credit card leak detection heuristic could also use much improvement. It currently only matches the major credit card provide formats available on sans.org. It also only matches numbers with either no separators between 4 number blocks or only ' ' or '-' characters. There are a variety of ways the number could conceivably be separated that would not be matched while still possibly being recognizable as a credit card number. In addition, there are many opportunities for false positives, as this will recognize any 16 digit number even if it is not a credit card number. It also might be possible that the number is in a large enough chunk of data that the data must be split over multiple packets. The number might then be split and not detectable.

In addition, the limitted number of heuristics used limits their abilities to detect incidents because there are many incidents not covered by them, such as attempts at SQL injection or other malicious activity.

## Further Development
With the current structure of the program, it would be rather time consuming to build in functionality to detect more Nmap scans, so I would first focus on adding more detectable incidents, such as improving the credit card detection heuristic and detecting SQL injection or other malicious activity that can be detected by observing a single packet.

The next step would be to build functionality into the program that will allow it to keep track of previous packets or certain information about them. This might allow for possible detection of SYN, connection, or ACK scans by being able to get counts of types of packets and compare for abnormalities that would indicate such a scan.

## Project Completion Information
I have implemented all parts of the project, including the extra credit. See usage for details regarding running with pcap files.

I spent somewhere around 9 hours on this assignment. Much of that time was due to issues with testing Nmap scans.

I discussed structuring programs in Ruby, the documentation and use of PacketFu, how to test the alarm, and how Ruby deals with regular expressions with or in the presence of Arthur Berman, Dylan Phelan, Colin Hamilton, Obaid Farooqui, and Reema Al-Marzoog.
