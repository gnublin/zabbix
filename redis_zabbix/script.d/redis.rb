#! /usr/bin/env ruby

require 'socket'
require 'getoptlong'
require 'pp'

@zabbixServer='localhost'
@zabbixPort='10051'


opts = GetoptLong.new(
    [ '--hostname', '-h', GetoptLong::REQUIRED_ARGUMENT ],
    [ '--port', '-p', GetoptLong::OPTIONAL_ARGUMENT ],
    [ '--help', GetoptLong::OPTIONAL_ARGUMENT ]
)

def help()
    puts ""
    puts "   Usage #{$0} : "
    puts "\t--hosname\t| -h \t hostname of redis instance (required)"
    puts "\t--port\t\t| -p \t port of redis instance (optional, default 6379)"
    puts "\t--help\t\t\t this help"
    puts ""
end

opts.each do |opt, arg|
    case opt 
        when '--hostname'
            @hostname=arg
        when '--port'
            @port=arg
            if arg == ''
            then
                @port=6379
            end
        when '--help'
            help
            exit
    end
end

if ! @hostname
        puts "Missing arguments. --hostname or -h required (try --help)"
            exit 0
end

fileName = File.basename(__FILE__)
dataFile="/tmp/#{fileName}_#{@hostname}.data"

socket = TCPSocket.open("#{@hostname}", "#{@port}")
socket.send("INFO\r\n", 0)

statistics = []
loop do
    data = socket.recv(4096)
        if !data || data.length == 0
            break
        end
        statistics << data
        if statistics.join.split(/\r\n/)[-1] =~ /db.*/
            break
        end
end

statistics=statistics.join()


@tablestat = Hash.new

statistics.each_line do |line|
if line.start_with?('#','$') or line.match(/^\r\n/)
    next
end

        line=line.to_s.gsub(/\r\n/,"")
        var = line.split(":")[0]
        value = line.split(":")[1]

            @tablestat["#{var}"] = "#{value}"
end

File.open("#{dataFile}", "w") {|ftruncate|
    ftruncate.truncate(0)
}

@tablestat.keys.each do |key|
    val = @tablestat[key]

    File.open("#{dataFile}", 'a+') {|f|
        f.write("\"#{@hostname}\" \"redis_#{key}\" \"#{val}\"\n") 
    }
end


system("/usr/bin/zabbix_sender -v -z #{@zabbixServer} -p #{@zabbixPort} -i #{dataFile}")

