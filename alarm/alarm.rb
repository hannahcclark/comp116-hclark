require 'packetfu'

class Alarm

    def search_log(logfile)
        incidents = 0
        File.readlines(logfile).each do |line|
            if line =~ /Nikto/
                incidents += 1
                puts "Nikto"
            elsif line =~ /((php)+(myadmin))|(myadmin)(php)+/i
                incidents += 1
                puts "phpmyadmin"
            elsif line =~ /masscan/
                incidents += 1
                puts "masscan"
            elsif line =~ /nmap/i
                incidents += 1
                puts "nmap"
            elsif line =~ /(shellshock-scan)|(\(\)\s*\{\s*:;\s*\}\; ping -c)/
                incidents += 1
                puts "shellshock"
            elsif line =~ /\/bin\/(bash|sh|perl)/
                incidents += 1
                puts "shellcode"
            end
        end
    end

    def sniff_packets(interface)
        incidents = 0
        stream = PacketFu::Capture.new(:start => true,
                                       :iface => interface,
                                       :promisc => true)
        stream.stream.each do |raw|
            packet = PacketFu::Packet.parse(raw)
            puts "***************************************"
            if packet.is_a?(PacketFu::TCPPacket)
                flags = packet.tcp_flags.to_i()
                if flags == 0
                    incidents += 1
                    puts "NULL"
                elsif flags == 1
                    incidents += 1
                    puts "FIN"
                elsif flags == 3
                    incidents += 1
                    puts "Maimon nmap scan"
                elsif flags == 
                elsif flags == 41
                    incidents += 1
                    puts "Xmas"
                end
            end
            if packet.payload() =~ /Nikto/
                incidents += 1
                puts "Nikto"
            elsif packet.payload( =~ /nmap/
                incidents += 1
                puts "nmap"
            elsif packet.payload() =~ \
                 /(((3|4|5)\d{3})|6011)(((-| )?\d{4}){3})/
                incidents += 1
                puts "Credit Card"
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

