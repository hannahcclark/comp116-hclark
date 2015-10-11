require 'packetfu'

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
            elsif line =~ /nmap/i
                incident_type = "Nmap scan"
            elsif line =~ /(shellshock-scan)|(\(\)\s*\{\s*:;\s*\}\; ping -c)/
                incident_type = "Someone attempting Shellshock"
            elsif line =~ /\/bin\/(bash|sh|perl)/
                incident_type = "Someone trying to execute shellcode"
            end
            
            if not incident_type.empty?
                incidents += 1
                puts incident_type
            end
        end
    end

    def sniff_packets(interface)
        incidents = 0
        stream = PacketFu::Capture.new(:start => true,
                                       :iface => interface,
                                       :promisc => true)
        stream.stream.each do |raw|
            incident_type = ""
            packet = PacketFu::Packet.parse(raw)
            payload = packet.payload
            puts "***************************************"
            if packet.is_a?(PacketFu::TCPPacket)
                flags = packet.tcp_flags.to_i
                if flags == 0
                    incident_type = "NULL scan"
                elsif flags == 1
                    incident_type = "FIN scan"
                elsif flags == 3
                    incident_type = "Maimon nmap scan"
                elsif flags == 41
                    incident_type"Xmas scan"
                end
            end
            if payload =~ /Nikto/
                incident_type = "Nikto scan"
            elsif payload =~ /nmap/
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
    if ARGV.length == 2 and ARGV[0] == "-r"
        alarm.search_log(ARGV[1])
    elsif ARGV.length == 0
        alarm.sniff_packets('eth0')
    else
        puts "Invalid Arguments"    
    end
end

