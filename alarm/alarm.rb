require 'packetfu'
require 'optparse'

# Alarm class to group together different types of alarms
#
class Alarm

    # Search contents of a log file in Apache common or combined log format
    # for Nikto scan, Masscan, Nmap scans, shellcode, shellshock, and phpmyadmin
    # stuff
    #
    def search_log(logfile)
        incidents = 0
        File.readlines(logfile).each do |line|
            # Scan each line and remember any incident found
            incident_type = ""
            if line =~ /Nikto/
                incident_type = "Nikto scan"
            elsif line =~ /((php)+(myadmin))|(myadmin)(php)+/i
                incident_type = "Someone looking for phpMyAdmin"
            elsif line =~ /masscan/
                incident_type = "Masscan scan"
            elsif line =~ /Nmap/
                incident_type = "Nmap scan"
            elsif line =~ /(\(\)\s*\{\s*:\;\s*\}\;)/
                incident_type = "Someone attempting Shellshock"
            elsif line =~ /(\\x\d\d)+/
                incident_type = "Someone trying to execute shellcode"
            end
            # Output if incident found
            if not incident_type.empty?
                incidents += 1
                # Breaks line into relevant components for Apache 
                # common/combined log format
                components = line.scan(
                    /(\d{1,3}.\d{1,3}.\d{1,3}.\d{1,3}) (.*) (.*) (\[.*\]) (")(.*)(") (\d+) (\d+|-)/)
                if components.empty?
                    abort("Bad File Format: Apache common log or " + 
                          "combined log formats only")
                else
                    components = components[0]
                end
                # index 5 is payload
                # Need to scan separately because shellcode causes payload
                # format to change
                payload = components[5].scan(/(.+) (.+) (.+)(\/.*)/)
                # If not possible to break payload into format with protocol
                if payload.empty?
                    # index 0 is IP, 5 is full payload
                    puts incidents.to_s + ". ALERT: " + incident_type +
                        " is detected from " + components[0] + 
                        " (UNKNOWN) (\"" + components[5] + "\")!"
                # Otherwise, use protocol found and rebuild payload in message
                else
                    # index 0 is IP, payload 2 is protocol, 0-3 is full payload
                    payload = payload[0]
                    puts incidents.to_s + ". ALERT: " + incident_type + 
                        " is detected from " + components[0] + " (" + 
                        payload[2] + ") (\"" + payload[0] + " " + 
                        payload[1] + " " + payload[2] + payload[3] + "\")!"
                end
            end
        end
    end

    # Search through packets, either a live stream or list from a pcap file for
    # incidents, including Nmap NULL, FIN, and Xmas scans, other somewhat
    # obvious Nmap scans, Nikto scans, and plaintext credit card leaks.
    # Packets may be either raw or already parsed.
    #
    def search_packets(packets)
        incidents = 0
        packets.each do |packet|
            # Check for raw packets
            if not packet.is_a?(PacketFu::Packet)
                packet = PacketFu::Packet.parse(packet)
            end
            incident_type = ""
            payload = packet.payload
            # Check TCPPackets for NULL/FIN/Xmas scan
            if packet.is_a?(PacketFu::TCPPacket)
                flags = packet.tcp_flags.to_i
                if flags == 0
                    incident_type = "NULL scan"
                elsif flags == 1
                    incident_type = "FIN scan"
                elsif flags == 41
                    incident_type = "Xmas scan"
                end
            end
            # Check payload for other incidents appearing there
            if payload =~ /Nikto/
                incident_type = "Nikto scan"
            elsif payload =~ /Nmap/
                incident_type = "Nmap scan"
            elsif payload =~ /(((3|4|5)\d{3})|6011)(((-| )?\d{4}){3})/
                incidents = "Plaintext credit card information leak"
            end
            # Output if incident found
            if not incident_type.empty?
                incidents += 1
                puts incidents.to_s + ". ALERT: " + incident_type + \
                    " is detected from " + packet.ip_saddr + " (" + \
                    packet.proto[-1] + ") (" + payload + ")!"
            end
        end
    end
end

# Separates off script from always running, so that the class could be used
# by other modules without running the script.
if __FILE__ == $0
    alarm = Alarm.new()
    options = {:log => nil, :pcap => nil}
    parser = OptionParser.new do|opts|
        opts.banner = "Usage: alarm.rb [options]\nDefaults to sniffing " + 
            "packets when no option specified."
        opts.on("-r", "--read-log logfile", "Log file to scan for incidents") \
        do |logfile|
            options[:log] = logfile
        end
        opts.on("-p", "--pcap-file pcap", "Pcap file to scan for incidents") \
        do |pcap|
            options[:pcap] = pcap
        end
        opts.on("-h", "--help", "Display help") do
            puts opts
            exit
        end
    end
    parser.parse!

    # Look through options provided. If both pcap and logfile are given,
    # search both. The incident count will be reset between files
    if options[:log]
        alarm.search_log(options[:log])
    end
    if options[:pcap]
        alarm.search_packets(PacketFu::PcapFile.read_packets(options[:pcap]))
    end
    # Default to sniffing network traffic if neither option provided
    if not (options[:pcap] or options[:log])
        alarm.search_packets(PacketFu::Capture.new(:start => true,
                                                   :iface => "eth0",
                                                   :promisc => true).stream)
    end
end

