require 'packetfu'

class Alarm

    def search_log(logfile)

    end

    def sniff_packets(interface)
        stream = PacketFu::Capture.new(:start => true,
                                       :iface => interface,
                                       :promisc => true)
        stream.stream.each do |raw|
            packet = PacketFu::Packet.parse(raw)
            if packet.is_a?(PacketFu::TCPPacket)
                flags = packet.tcp_flags.to_i()
                if flags == 0
                    puts "NULL"
                elsif flags == 1
                    puts "FIN"
                elsif flags == 41
                    puts "XMAS"
            end
        end
    end
end

if __FILE__ == $0
    alarm = Alarm.new()
    alarm.sniff_packets('eth0')
end

