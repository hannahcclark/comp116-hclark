require 'packetfu'
require 'optparse'

class Alarm

    def search_log(logfile)
        incidents = 0
        File.readlines(logfile).each do |line|
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
            
            if not incident_type.empty?
                incidents += 1
                components = line.scan(
                    /(\d{1,3}.\d{1,3}.\d{1,3}.\d{1,3}) (.*) (.*) (\[.*\]) (")(.+) (.+) (.+)(\/.*)(") (\d+) (\d+|-)/)
                if components.empty?
                    abort("Bad File Format: Apache common log or " + 
                          "combined log formats only")
                else
                    components = components[0]
                end
                #0 is IP, 7 is protocol without version, 5-8 are full payload
                puts incidents.to_s + ". ALERT: " + incident_type + 
                    " is detected from " + components[0] + " (" + 
                    components[7] + ") (\"" + components[5] + " " + 
                    components[6] + " " + components[7] + components[8] + "\")!"
            end
        end
    end

    def search_packets(packets)
        incidents = 0
        packets.each do |raw|
            incident_type = ""
            packet = PacketFu::Packet.parse(raw)
            payload = packet.payload
            if packet.is_a?(PacketFu::TCPPacket)
                flags = packet.tcp_flags.to_i
                if flags == 0
                    incident_type = "NULL scan"
                elsif flags == 1
                    incident_type = "FIN scan"
                elsif flags == 41
                    incident_type"Xmas scan"
                end
            end
            if payload =~ /Nikto/
                incident_type = "Nikto scan"
            elsif payload =~ /Nmap/
                incident_type = "Nmap scan"
            elsif payload =~ /(((3|4|5)\d{3})|6011)(((-| )?\d{4}){3})/
                incidents = "Plaintext credit card information leak"
            end
            if not incident_type.empty?
                incidents += 1
                puts incidents.to_s + ". ALERT: " + incident_type + \
                    " is detected from " + packet.ip_saddr + " (" + \
                    packet.proto[-1] + ") (" + payload + ")!"
            end
        end
    end
end

if __FILE__ == $0
    alarm = Alarm.new()
    options = {:log => nil, :pcap => nil}
    parser = OptionParser.new do|opts|
        opts.banner = "Usage: alarm.rb [options]"
        opts.on("-r", "--read-log logfile", "Log file to scan for incidents") \
        do |logfile|
            options[:log] = logfile
        end
        opts.on("-p", "--pcap-file pcap", "Pcap file to scan for incidents") \
        do |pcap|
            options[:pcap] = pcap
        end
        opts.on("-h", "--help", "Display help") do
            puts ops
            exit
        end
    parser.parse!

    if options[:log]
        alarm.search_log(ARGV[1])
    elsif options[:pcap]
        alarm.search_packets(PacketFu::PcapFile.read_packets(pcap))
    else
         stream = PacketFu::Capture.new(:start => true,
                                        :iface => "eth0",
                                        :promisc => true)

        alarm.search_packets(PacketFu::Capture.new(:start => true,
                                                   :iface => interface,
                                                    :promisc => true).stream)
    end
end

